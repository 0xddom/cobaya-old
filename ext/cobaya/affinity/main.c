#include <ruby.h>

VALUE Cobaya = Qnil;
VALUE Affinity = Qnil;

void Init_affinity(void);
static VALUE choose_available_cpu(VALUE);


void Init_affinity() {
  Cobaya = rb_define_module("Cobaya");
  Affinity = rb_define_module_under(Cobaya, "Affinity");

  rb_define_singleton_method(CPUAffinity, "choose_available_cpu",
			     choose_available_cpu, 0);
}

static VALUE choose_available_cpu(VALUE self) {
  
  return INT2FIX(0);
}
