/*
* proxy.c
* token filter for ltokenp
* Luiz Henrique de Figueiredo <lhf@tecgraf.puc-rio.br>
* 30 Jul 2018 19:34:04
* This code is hereby placed in the public domain and also under the MIT license
*/

#include "ltokenp.h"

#if LUA_VERSION_NUM < 503
#define TK_INT	(-1)
#define TK_FLT	TK_NUMBER
#endif

#ifdef LTOKENP_T
int filter_comment(LexState* X)
{
	lua_State* L = X->L;
	if (!FILTERING)
	{
		return 0;
	}
	lua_getglobal(L, FILTER_COMMENT);
	if (X->cb_type == TK_LIENBREAKS)
	{
		lua_pushinteger(L, X->linenumber-1);
	}
	else
	{
		lua_pushinteger(L, X->linenumber);
	}
	lua_pushinteger(L, X->cb_type);
	if (X->cb_type < FIRST_RESERVED)
	{
		char s[2] = { X->cb_type,0 };
		lua_pushstring(L, s);
	}
	else
	{
		lua_pushstring(L, luaX_tokens[X->cb_type - FIRST_RESERVED]);
	}
	lua_pushlstring(L, luaZ_buffer(X->cbuff), luaZ_bufflen(X->cbuff));
	lua_pushlstring(L, luaZ_buffer(X->cbuff), luaZ_bufflen(X->cbuff));
	lua_call(L, 5, 0);
	return 0;
}
#endif

static int filter(LexState *X, SemInfo *seminfo)
{
 lua_State *L=X->L;
 lua_getglobal(L,FILTER);
 lua_pushinteger(L,0);
 lua_pushinteger(L,-1);
 lua_pushstring(L,"<file>");
 lua_pushstring(L,getstr(X->source));
#ifdef LTOKENP_T
 lua_pushlstring(L, luaZ_buffer(X->cbuff), luaZ_bufflen(X->cbuff));
 lua_call(L, 5, 0);
#else
 lua_call(L,4,0);
#endif

 for (;;)
 {
  int t=llex(X,seminfo);
  lua_getglobal(L,FILTER);
  lua_pushinteger(L,X->linenumber);
  lua_pushinteger(L,t);
  if (t<FIRST_RESERVED)
  {
   char s[2]= {t,0};
   lua_pushstring(L,s);
  }
  else
   lua_pushstring(L,luaX_tokens[t-FIRST_RESERVED]);
  switch (t)
  {
    case TK_STRING:
    case TK_NAME:
     lua_pushstring(L,getstr(seminfo->ts));
     break;
    case TK_INT:
    case TK_FLT:
     lua_pushstring(L,X->buff->buffer);
     break;
    default:
     lua_pushvalue(L,-1);
     break;
  }
#ifdef LTOKENP_T
  lua_pushlstring(L, luaZ_buffer(X->cbuff), luaZ_bufflen(X->cbuff));
  lua_call(L,5,0);
#else
  lua_call(L,4,0);
#endif

  if (t==TK_EOS) return t;
 }
}

static int nexttoken(LexState *X, SemInfo *seminfo)
{
 if (FILTERING)
  return filter(X,seminfo);
 else
  return llex(X,seminfo);
}

#define llex nexttoken
