#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char* argv[]) {

  extern char** environ; /* current executing environment */
 
  char *newargv[] = { NULL, "

  printf("\nArguments:\n");

  for (int i = 0; i < argc; i++) {
    printf("%d -> %s\n", i, argv[i]);
  }

  printf("\n");

  if (argc != 2) {
    fprintf(stderr, "Usage: %s <file-to-exec>\n", argv[0]);
    exit(EXIT_FAILURE);
  }

  newargv[0] = argv[1];

  execve(argv[1], newargv, newenviron);
  perror("execve");   /* execve() returns only on error */
  exit(EXIT_FAILURE);


}

/*
 * indirect--
 *
 * Provides 'shebang' exec calls which are directly handed off to an 
 * interpreter to process hooks based the name of this executable: argv[0]. 
 * This replicates the funcationlity of env(1) except in that the processing of
 * options are handled by the script matching the name of this executable.
 *
 * This allows an interpreter and a custom set of scripts to be used without 
 * having to write a custom interpreter to handle option management. It also
 * enables easy branding of the 'shebang' line eliminating the need to have the
 * interpreter listed as an the first option following '/usr/bin/env'
 *
 * Specifically this was created to allow tcl scripts to process shebang lines.
 *
 * EXAMPLE
 *
 *   cp indirect /usr/bin/indirect
 *   ln -s /usr/bin/indirect /usr/bin/interpfoo
 *
 *   cat <<INTERPFOO_SCRIPT > /usb/sbin/interpfoo
 *   #!/usr/bin/tclsh
 *
 *     # THIS FILE PERFORMS THE SHEBANG PROCESSING AND HANDS OFF TO INTERPRETER
 *     
 *     
 *     }
 *
 *
 *   INTERPFOO_SCRIPT
 *
 */
