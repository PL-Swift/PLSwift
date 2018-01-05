#ifndef __PLSwiftShim_H__
#define __PLSwiftShim_H__

#include "postgres.h"

// for PG_GETARG_XXX, PG_RETURN_XXX
// also:  PG_MODULE_MAGIC
#include "fmgr.h"

// for cstring_to_text
#include "utils/builtins.h"

#endif /* __PLSwiftShim_H__ */
