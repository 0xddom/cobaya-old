#define _GNU_SOURCE 1

#include <ruby.h>

#include <ctype.h>
#include <stdlib.h>
#include <dirent.h>
#include <errno.h>

#if defined(__linux__)
#include <sched.h>
#include <unistd.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_LINE 8192

#define EPROC -1
#define EFULL -3

// Modules
VALUE Cobaya = Qnil;
VALUE Affinity = Qnil;

// Exceptions
VALUE eUnsupportedPlatform = Qnil;
VALUE eCPUNotSet = Qnil;
#define raise_cpu_err(cpu_id) rb_raise (eCPUNotSet, "Couldn't set the affinity to the CPU %d", cpu_id)
#define raise_unsp_pltf rb_raise (eUnsupportedPlatform, "This platform doesn't support CPU affinity")

// Function definitions
void Init_affinity(void);
static VALUE choose_available_cpu(VALUE);
static VALUE set_to_cpu(VALUE, VALUE);
static VALUE is_supported(VALUE);

// Internal functions
static int set_cpu_affinity(int);
static int select_available_cpu(void);

/**
 * Initializes the native ruby module
 */
void Init_affinity() {
  Cobaya = rb_define_module ("Cobaya");
  Affinity = rb_define_module_under (Cobaya, "Affinity");

  rb_define_singleton_method (Affinity, "choose_available_cpu",
			      choose_available_cpu, 0);
  rb_define_singleton_method (Affinity, "set",
			      set_to_cpu, 1);
  rb_define_singleton_method (Affinity, "supported?",
			      is_supported, 0);

  eUnsupportedPlatform = rb_define_class_under (Affinity, "UnsupportedPlatformError",
						rb_eRuntimeError);
  eCPUNotSet = rb_define_class_under (Affinity, "CPUNotSetError",
				      rb_eRuntimeError);
}

/**
 * Returns true if CPU affinity is supported.
 * False on the contrary.
 */
static VALUE is_supported(VALUE self) {
#if defined(__linux__)
  return Qtrue;
#else
  return Qfalse;
#endif
}

/**
 * Sets the affinity to an specific CPU.
 * Raises an exception is it was not possible.
 */
static VALUE set_to_cpu(VALUE self, VALUE cpu) {
#if defined(__linux__)
  int cpu_id = (int)FIX2INT (cpu);
  int result;

  result = set_cpu_affinity (cpu_id);
  if (result < 0) {
    raise_cpu_err (cpu_id);
  }

  return Qnil;
#else
  raise_unsp_pltf;
#endif
}

/**
 * Looks for a free cpu and sets the affinity to it.
 * Returns the ID of the CPU. Raises an exception if
 * is not a supported platform or if an available
 * CPU was not found.
 */
static VALUE choose_available_cpu(VALUE self) {
#if defined(__linux__)
  int result;
  int cpu = 0;
  const char *err_msg;

  cpu = select_available_cpu ();
  if (cpu < 0) {
    switch (errno) {
    case EPROC:
      err_msg = "Couldn't open /proc. Can't scan for free CPU cores";
      break;
    case EFULL:
      err_msg = "Couldn't find a free CPU core";
      break;
    default:
      err_msg = "Unknow error";
      break;
    }
    rb_raise (eCPUNotSet, err_msg);
  }
  
  result = set_cpu_affinity (cpu);
  if (result < 0) {
    raise_cpu_err (cpu);
  }
  
  return INT2FIX (cpu);
#else
  raise_unsp_pltf;
#endif
}

/**
 * Sets the CPU affinity. Returns -1 if it was not possible.
 */
static int set_cpu_affinity(int cpu_id) {
  cpu_set_t mask;

  CPU_ZERO (&mask);
  CPU_SET (cpu_id, &mask);

  return sched_setaffinity (getpid (), sizeof (mask), &mask);
}

/**
 * Looks for a free CPU core. Returns -1 if nothing found and
 * errno is set.
 */
static int select_available_cpu() {
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


#ifdef __cplusplus
}
#endif
