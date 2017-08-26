#include "affinity.h"
#include <ctype.h>
#include <stdlib.h>
#include <dirent.h>
#include <errno.h>
#if SUPPORTED_PLATFORM
#include <sched.h>
#include <unistd.h>


#define MAX_LINE 8192

/*
 * Sets the CPU affinity. Returns -1 if it was not possible.
 */
int set_cpu_affinity(int cpu_id) {
  cpu_set_t mask;

  CPU_ZERO (&mask);
  CPU_SET (cpu_id, &mask);

  return sched_setaffinity (getpid (), sizeof (mask), &mask);
}

/*
 * Looks for a free CPU core. Returns -1 if nothing found and
 * errno is set.
 */
int select_available_cpu() {
  DIR *d;
  struct dirent* de;
  char cpu_used[4096] = { 0 };
  int cpu_id;

  int cpu_core_count = sysconf (_SC_NPROCESSORS_ONLN);

  d = opendir ("/proc");

  if (!d) {
    errno = EPROC;
    return -1;
  }
  
  while (de = readdir (d)) {
    char *proc_fn = NULL;
    FILE *f = NULL;
    char tmp[MAX_LINE];
    char has_vmsize = 0;
    int len;

    if (!isdigit (de->d_name[0])) goto cleanup;
    
    len = snprintf (NULL, 0, "/proc/%s/status", de->d_name);
    proc_fn = (char *)calloc (1, len + 1);
    snprintf (proc_fn, len + 1, "/proc/%s/status", de->d_name);

    if (!(f = fopen(proc_fn, "r"))) {
      goto cleanup;
    }

    // From afl/afl-fuzz.c
    while (fgets (tmp, MAX_LINE, f)) {
      unsigned int hval;

      if (!strncmp (tmp, "VmSize:\t", 8)) has_vmsize = 1;

      if (!strncmp (tmp, "Cpus_allowed_list:\t", 19) &&
	  !strchr (tmp, '-') && !strchr (tmp, ',') &&
	  sscanf (tmp + 19, "%u", &hval) == 1 && hval < sizeof (cpu_used) &&
	  has_vmsize) {
	cpu_used[hval] = 1;
	break;
      }
	  
    }

    
  cleanup:
    if (proc_fn) free (proc_fn);
    if (f) fclose (f);
  }

  closedir (d);

  for (cpu_id = 0; cpu_id < cpu_core_count; cpu_id++)
    if (!cpu_used[cpu_id]) break;

  if (cpu_id == cpu_core_count) {
    errno = EFULL;
    return -1;
  }

  return cpu_id;
}

#endif
