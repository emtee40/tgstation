<<<<<<< HEAD
#define GENERAL_PROTECT_DATUM(Path)\
##Path/can_vv_get(var_name){\
    return FALSE;\
}\
##Path/vv_edit_var(var_name, var_value){\
    return FALSE;\
}\
##Path/CanProcCall(procname){\
    return FALSE;\
=======
#define GENERAL_PROTECT_DATUM(Path)\
##Path/can_vv_get(var_name){\
    return FALSE;\
}\
##Path/vv_edit_var(var_name, var_value){\
    return FALSE;\
}\
##Path/CanProcCall(procname){\
    return FALSE;\
>>>>>>> Updated this old code to fork
}