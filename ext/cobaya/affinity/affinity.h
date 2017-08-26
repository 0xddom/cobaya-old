#ifndef _COBAYA_AFFINITY_AFFINITY_H
#define _COBAYA_AFFINITY_AFFINITY_H

#define SUPPORTED_PLATFORM defined(__linux__)

#if SUPPORTED_PLATFORM

#define _GNU_SOURCE 1

#define EPROC -1
#define EFULL -3

#ifdef __cpluplus
extern "C" {
#endif // __cplusplus

int set_cpu_affinity(int);
int select_available_cpu(void);


#ifdef __cpluplus
}
#endif // __cplusplus

#endif // SUPPORTED_PLATFORM

#endif // _COBAYA_AFFINITY_AFFINITY_H
