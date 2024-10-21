/*
* ltokenp.c
* Lua token processor
* Luiz Henrique de Figueiredo <lhf@tecgraf.puc-rio.br>
* 24 Jan 2023 13:59:18
* This code is hereby placed in the public domain and also under the MIT license
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "ltokenp.h"

#if LUA_VERSION_NUM < 502
#define COPYRIGHT LUA_RELEASE "  " LUA_COPYRIGHT
#else
#define COPYRIGHT LUA_COPYRIGHT
#endif

static const char *progname="ltokenp";
int FILTERING=0;			/* read by proxy.c */

static void fatal(const char *message)
{
 fprintf(stderr,"%s: %s\n",progname,message);
 exit(EXIT_FAILURE);
}

static void load(lua_State *L, const char *file, int filtering)
{
 int rc;
 FILTERING=filtering;
 if (filtering)
  rc=luaL_loadfile(L,file);
 else
  rc=luaL_dofile(L,file);
 if (rc!=0) fatal(lua_tostring(L,-1));
 lua_settop(L,0);
}

int main(int argc, char *argv[])
{
 int i;
 lua_State *L=luaL_newstate();
 (void) argc;
 if (argv[0]!=NULL && *argv[0]!=0) progname=argv[0];
 if (L==NULL) fatal("not enough memory for state");
 luaL_openlibs(L);
 lua_getglobal(L,"print");
 lua_setglobal(L,FILTER);
 lua_getglobal(L,"print");
 lua_setglobal(L, FILTER_COMMENT);
 for (i=1; i<argc; i++)
 {
  if (strcmp(argv[i],"-v")==0)
   printf("%s\n",COPYRIGHT);
  else if (strcmp(argv[i],"-s")==0)
  {
   i++;
   if (argv[i]==NULL || argv[i][0]=='-') fatal("-s needs argument");
   load(L,argv[i],0);
  }
  else if (strcmp(argv[i],"-")==0)
   load(L,NULL,1);
  else
   load(L,argv[i],1);
 }
 lua_close(L);
 return EXIT_SUCCESS;
}
