#include <ruby.h>
#include "affinity.h"

#ifdef __cplusplus
extern "C" {
#endif

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

/*
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

/*
 * Returns true if CPU affinity is supported.
 * False on the contrary.
 */
static VALUE is_supported(VALUE self) {
#if SUPPORTED_PLATFORM
  return Qtrue;
#else
  return Qfalse;
#endif
}

/*
 * Sets the affinity to an specific CPU.
 * Raises an exception is it was not possible.
 */
static VALUE set_to_cpu(VALUE self, VALUE cpu) {
#if SUPPORTED_PLATFORM
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

/*
 * Looks for a free cpu and sets the affinity to it.
 * Returns the ID of the CPU. Raises an exception if
 * is not a supported platform or if an available
 * CPU was not found.
 */
static VALUE choose_available_cpu(VALUE self) {
#if SUPPORTED_PLATFORM
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

#ifdef __cplusplus
}
#endif
