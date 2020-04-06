dict set tclbcc operations {
  done {
    args {}
    description {
      Finish ByteCode execution and return stktop (top stack item)
    }
    stackaction {... value => TERMINATE}
  }
  push1 {
    args {LIT1}
    description {
      Push object at ByteCode objArray[op1]
    }
    stackaction {... => ... value}
  }
  push4 {
    args {LIT4}
    description {
      Push object at ByteCode objArray[op4]
    }
    stackaction {... => ... value}
  }
  nop {
    args {}
    description {
      Do nothing
    }
    stackaction {... => ...}
  }
  pop {
    args {}
    description {
      Pop the topmost stack object
    }
    stackaction {... value => ...}
  }
  dup {
    args {}
    description {
      Duplicate the topmost stack object and push the result
    }
    stackaction {... value => ... value value}
  }
  over {
    args {UINT4}
    description {
      Duplicate the arg-th element from top of stack (TOS=0)
    }
    stackaction {... valN valN-1 valN-2 ... val1 val0 => ... valN valN-1 valN-2 ... val1 val0 valN}
  }
  reverse {
    args {UINT4}
    description {
      Reverse the order of the arg elements at the top of stack
    }
    stackaction {... valN valN-1 ... val1 => ... val1 ... valN-1 valN}
  }
  break {
    args {}
    description {
      Abort closest enclosing loop; if none, return TCL_BREAK code.
    }
  }
  continue {
    args {}
    description {
      Skip to next iteration of closest enclosing loop; if none, return 
      TCL_CONTINUE code.
    }
  }
  beginCatch4 {
    args {UINT4}
    description {
      Record start of catch with the operand's exception index. Push the 
      current stack depth onto a special catch stack.
    }
  }
  endCatch {
    args {}
    description {
      End of last catch. Pop the bytecode interpreter's catch stack. Must 
      have the same stack depth as the beginCatch4 that it matches.
    }
  }
  pushResult {
    args {}
    description {
      Push the interpreter's object result onto the stack.
    }
    stackaction {... => ... result}
  }
  pushReturnCode {
    args {}
    description {
      Push interpreter's return code (e.g. TCL_OK or TCL_ERROR) as a new 
      object onto the stack.
    }
    stackaction {... => ... code}
  }
  pushReturnOpts {
    args {}
    description {
      Push the interpreter's return option dictionary as an object on the stack.
    }
    stackaction {... => ... optDict}
  }
  returnStk {
    args {}
    description {
      Compiled return; options and result are on the stack, code and level 
      are in the options.
    }
  }
  returnImm {
    args {INT4 UINT4}
    description {
      Compiled return, code, level are operands; options and result are on 
      the stack.
    }
  }
  syntax {
    args {INT4 UINT4}
    description {
      Compiled bytecodes to signal syntax error. Equivalent to returnImm 
      except for the ERR_ALREADY_LOGGED flag in the interpreter.
    }
  }
  jump1 {
    args {OFFSET1}
    description {
      Jump relative to (pc + op1)
    }
  }
  jump4 {
    args {OFFSET4}
    description {
      Jump relative to (pc + op4)
    }
  }
  jumpTrue1 {
    args {OFFSET1}
    description {
      Jump relative to (pc + op1) if stktop expr object is true
    }
  }
  jumpTrue4 {
    args {OFFSET4}
    description {
      Jump relative to (pc + op4) if stktop expr object is true
    }
  }
  jumpFalse1 {
    args {OFFSET1}
    description {
      Jump relative to (pc + op1) if stktop expr object is false
    }
  }
  jumpFalse4 {
    args {OFFSET4}
    description {
      Jump relative to (pc + op4) if stktop expr object is false
    }
  }
  startCommand {
    args {OFFSET4 UINT4}
    description {
      Start of bytecoded command: op is the length of the cmd's code, op2 
      is number of commands here
    }
  }
  jumpTable {
    args {AUX4}
    description {
      Jump according to the jump-table (in AuxData as indicated by the 
      operand) and the argument popped from the list. Always executes the 
      next instruction if no match against the table's entries was found.
    }
    stackaction {... value => ...#
      Note that the jump table contains offsets relative to the PC when 
      it points to this instruction; the code is relocatable.
    }
  }
  returnCodeBranch {
    args {}
    description {
      Jump to next instruction based on the return code on top of stack 
      ERROR: +1; RETURN: +3; BREAK: +5; CONTINUE: +7; Other non-OK: +9
    }
  }
  yield {
    args {}
    description {
      Makes the current coroutine yield the value at the top of the stack, 
      and places the response back on top of the stack when it resumes.
    }
    stackaction {... valueToYield => ... resumeValue}
  }
  tailcall {
    args {UINT1}
    description {
      Do a tailcall with the opnd items on the stack as the thing to 
      tailcall to; opnd must be greater than 0 for the semantics to work 
      right.
    }
  }
  yieldToInvoke {
    args {}
    description {
      Makes the current coroutine yield the value at the top of the stack, 
      invoking the given command/args with resolution in the given 
      namespace (all packed into a list), and places the list of values 
      that are the response back on top of the stack when it resumes.
    }
    stackaction {... [list ns cmd arg1 ... argN] => ... resumeList}
  }
  strcat {
    args {UINT1}
    description {
      Concatenate the top op1 items and push result
    }
  }
  streq {
    args {}
    description {
      Str Equal: push (stknext eq stktop)
    }
  }
  strneq {
    args {}
    description {
      Str !Equal: push (stknext neq stktop)
    }
  }
  strcmp {
    args {}
    description {
      Str Compare: push (stknext cmp stktop)
    }
  }
  strlen {
    args {}
    description {
      Str Length: push (strlen stktop)
    }
  }
  strindex {
    args {}
    description {
      Str Index: push (strindex stknext stktop)
    }
  }
  strmatch {
    args {INT1}
    description {
      Str Match: push (strmatch stknext stktop) opnd == nocase
    }
  }
  strmap {
    args {}
    description {
      Simplified version of string map that only applies one change string, 
      and only case-sensitively.
    }
    stackaction {... from to string => ... changedString}
  }
  strfind {
    args {}
    description {
      Find the first index of a needle string in a haystack string, 
      producing the index (integer) or -1 if nothing found.
    }
    stackaction {... needle haystack => ... index}
  }
  strrfind {
    args {}
    description {
      Find the last index of a needle string in a haystack string, 
      producing the index (integer) or -1 if nothing found.
    }
    stackaction {... needle haystack => ... index}
  }
  strrangeImm {
    args {IDX4 IDX4}
    description {
      String Range: push (string range stktop op4 op4)
    }
  }
  strrange {
    args {}
    description {
      String Range with non-constant arguments.
    }
    stackaction {... string idxA idxB => ... substring}
  }
  strtrim {
    args {}
    description {
      string trim core: removes the characters (designated by the value at 
      the top of the stack) from both ends of the string and pushes the 
      resulting string.
    }
    stackaction {... string charset => ... trimmedString}
  }
  strtrimLeft {
    args {}
    description {
      string trimleft core: removes the characters (designated by the value 
      at the top of the stack) from the left of the string and pushes the 
      resulting string.
    }
    stackaction {... string charset => ... trimmedString}
  }
  strtrimRight {
    args {}
    description {
      string trimright core: removes the characters (designated by the 
      value at the top of the stack) from the right of the string and pushes 
      the resulting string.
    }
    stackaction {... string charset => ... trimmedString}
  }
  strcaseUpper {
    args {}
    description {
      string toupper core: converts whole string to upper case using the 
      default (extended "C" locale) rules.
    }
    stackaction {... string => ... newString}
  }
  strcaseLower {
    args {}
    description {
      string tolower core: converts whole string to upper case using the 
      default (extended "C" locale) rules.
    }
    stackaction {... string => ... newString}
  }
  strcaseTitle {
    args {}
    description {
      string totitle core: converts whole string to upper case using the 
      default (extended "C" locale) rules.
    }
    stackaction {... string => ... newString}
  }
  strreplace {
    args {}
    description {
      string replace core: replaces a non-empty range of one string with 
      the contents of another.
    }
    stackaction {... string fromIdx toIdx replacement => ... newString}
  }
  strclass {
    args {SCLS1}
    description {
      See if all the characters of the given string are a member of the 
      specified (by opnd) character class. Note that an empty string will 
      satisfy the class check (standard definition of "all").
    }
    stackaction {... stringValue => ... boolean}
  }
  regexp {
    args {INT1}
    description {
      Regexp: push (regexp stknext stktop) opnd == nocase
    }
  }
  evalStk {
    args {}
    description {
      Evaluate command in stktop using Tcl_EvalObj.
    }
  }
  exprStk {
    args {}
    description {
      Execute expression in stktop using Tcl_ExprStringObj.
    }
  }
  invokeStk1 {
    args {UINT1}
    description {
      Invoke command named objv[0]; <objc,objv> = <op1,top op1>
    }
  }
  invokeStk4 {
    args {UINT4}
    description {
      Invoke command named objv[0]; <objc,objv> = <op4,top op4>
    }
  }
  invokeReplace {
    args {UINT4 UINT1}
    description {
      Invoke command named objv[0], replacing the first two words with the 
      word at the top of the stack;
      <objc,objv> = <op4,top op4 after popping 1>
    }
  }
  callBuiltinFunc1 {
    args {UINT1}
    description {
      Call builtin math function with index op1; any args are on stk. 
      OBSOLETE!
    }
  }
  callFunc1 {
    args {UINT1}
    description {
      Call non-builtin func objv[0]; <objc,objv>=<op1,top op1> OBSOLETE!
    }
  }
  expandStart {
    args {}
    description {
      Start of command with {*} (expanded) arguments
    }
  }
  expandStkTop {
    args {UINT4}
    description {
      Expand the list at stacktop: push its elements on the stack

      NOTE: the stack effects of expandStkTop and invokeExpanded are wrong - 
      but it cannot be done right at compile time, the stack effect is only 
      known at run time. The value for invokeExpanded is estimated better at 
      compile time.
      
      See the comments in tclCompile.c, where invokeExpanded is emitted.
    }
  }
  invokeExpanded {
    args {}
    description {
      Invoke the command marked by the last expandStart
      
      NOTE: the stack effects of expandStkTop and invokeExpanded are wrong - 
      but it cannot be done right at compile time, the stack effect is only 
      known at run time. The value for invokeExpanded is estimated better at 
      compile time.
      
      See the comments in tclCompile.c, where invokeExpanded is emitted.
    }
  }
  expandDrop {
    args {}
    description {
      Drops an element from the auxiliary stack, popping stack elements until
      the matching stack depth is reached.
    }
  }
  loadScalar1 {
    args {LVT1}
    description {
      Load scalar variable at index op1 <= 255 in call frame
    }
  }
  loadScalar4 {
    args {LVT4}
    description {
      Load scalar variable at index op1 >= 256 in call frame
    }
  }
  loadScalarStk {
    args {}
    description {
      Load scalar variable; scalar's name is stktop. NEVER ISSUED.
    }
  }
  loadArray1 {
    args {LVT1}
    description {
      Load array element; array at slot op1<=255, element is stktop
    }
  }
  loadArray4 {
    args {LVT4}
    description {
      Load array element; array at slot op1 > 255, element is stktop
    }
  }
  loadArrayStk {
    args {}
    description {
      Load array element; element is stktop, array name is stknext
    }
  }
  loadStk {
    args {}
    description {
      Load general variable; unparsed variable name is stktop
    }
  }
  storeScalar1 {
    args {LVT1}
    description {
      Store scalar variable at op1<=255 in frame; value is stktop
    }
  }
  storeScalar4 {
    args {LVT4}
    description {
      Store scalar variable at op1 > 255 in frame; value is stktop
    }
  }
  storeScalarStk {
    args {}
    description {
      Store scalar; value is stktop, scalar name is stknext. NEVER ISSUED.
    }
  }
  storeArray1 {
    args {LVT1}
    description {
      Store array element; array at op1<=255, value is top then elem
    }
  }
  storeArray4 {
    args {LVT4}
    description {
      Store array element; array at op1>=256, value is top then elem
    }
  }
  storeArrayStk {
    args {}
    description {
      Store array element; value is stktop, then elem, array names
    }
  }
  storeStk {
    args {}
    description {
      Store general variable; value is stktop, then unparsed name
    }
  }
  existScalar {
    args {LVT4}
    description {
      Test if scalar variable at index op1 in call frame exists
    }
  }
  existArray {
    args {LVT4}
    description {
      Test if array element exists; array at slot op1, element is stktop
    }
  }
  existArrayStk {
    args {}
    description {
      Test if array element exists; element is stktop, array name is stknext
    }
  }
  existStk {
    args {}
    description {
      Test if general variable exists; unparsed variable name is stktop
    }
  }
  unsetScalar {
    args {UINT1 LVT4}
    description {
      Make scalar variable at index op2 in call frame cease to exist; op1 
      is 1 for errors on problems, 0 otherwise
    }
  }
  unsetArray {
    args {UINT1 LVT4}
    description {
      Make array element cease to exist; array at slot op2, element is 
      stktop; op1 is 1 for errors on problems, 0 otherwise
    }
  }
  unsetArrayStk {
    args {UINT1}
    description {
      Make array element cease to exist; element is stktop, array name is 
      stknext; op1 is 1 for errors on problems, 0 otherwise
    }
  }
  unsetStk {
    args {UINT1}
    description {
      Make general variable cease to exist; unparsed variable name is 
      stktop; op1 is 1 for errors on problems, 0 otherwise
    }
  }
  upvar {
    args {LVT4}
    description {
      finds level and otherName in stack, links to local variable at index 
      op1. Leaves the level on stack.
    }
  }
  nsupvar {
    args {LVT4}
    description {
      finds namespace and otherName in stack, links to local variable at 
      index op1. Leaves the namespace on stack.
    }
  }
  variable {
    args {LVT4}
    description {
      finds namespace and otherName in stack, links to local variable at 
      index op1. Leaves the namespace on stack.
    }
  }
  incrScalar1 {
    args {LVT1}
    description {
      Incr scalar at index op1<=255 in frame; incr amount is stktop
    }
  }
  incrScalarStk {
    args {}
    description {
      Incr scalar; incr amount is stktop, scalar's name is stknext. NEVER 
      ISSUED.
    }
  }
  incrArray1 {
    args {LVT1}
    description {
      Incr array elem; arr at slot op1<=255, amount is top then elem
    }
  }
  incrArrayStk {
    args {}
    description {
      Incr array element; amount is top then elem then array names
    }
  }
  incrStk {
    args {}
    description {
      Incr general variable; amount is stktop then unparsed var name
    }
  }
  incrScalar1Imm {
    args {LVT1 INT1}
    description {
      Incr scalar at slot op1 <= 255; amount is 2nd operand byte
    }
  }
  incrScalarStkImm {
    args {INT1}
    description {
      Incr scalar; scalar name is stktop; incr amount is op1. NEVER ISSUED.
    }
  }
  incrArray1Imm {
    args {LVT1 INT1}
    description {
      Incr array elem; array at slot op1 <= 255, elem is stktop, amount is 
      2nd operand byte
    }
  }
  incrArrayStkImm {
    args {INT1}
    description {
      Incr array element; elem is top then array name, amount is op1
    }
  }
  incrStkImm {
    args {INT1}
    description {
      Incr general variable; unparsed name is top, amount is op1
    }
  }
  appendScalar1 {
    args {LVT1}
    description {
      Append scalar variable at op1<=255 in frame; value is stktop
    }
  }
  appendScalar4 {
    args {LVT4}
    description {
      Append scalar variable at op1 > 255 in frame; value is stktop
    }
  }
  appendArray1 {
    args {LVT1}
    description {
      Append array element; array at op1<=255, value is top then elem
    }
  }
  appendArray4 {
    args {LVT4}
    description {
      Append array element; array at op1>=256, value is top then elem
    }
  }
  appendArrayStk {
    args {}
    description {
      Append array element; value is stktop, then elem, array names
    }
  }
  appendStk {
    args {}
    description {
      Append general variable; value is stktop, then unparsed name
    }
  }
  lor {
    args {}
    description {
      Logical or: `push (stknext  stktop)`
    }
  }
  land {
    args {}
    description {
      Logical and: push (stknext && stktop)
    }
  }
  bitor {
    args {}
    description {
      Bitwise or: `push (stknext stktop)`
    }
  }
  bitxor {
    args {}
    description {
      Bitwise xor push (stknext ^ stktop)
    }
  }
  bitand {
    args {}
    description {
      Bitwise and: push (stknext & stktop)
    }
  }
  eq {
    args {}
    description {
      Equal: push (stknext == stktop)
    }
  }
  neq {
    args {}
    description {
      Not equal: push (stknext != stktop)
    }
  }
  lt {
    args {}
    description {
      Less: push (stknext < stktop)
    }
  }
  gt {
    args {}
    description {
      Greater: push (stknext > stktop)
    }
  }
  le {
    args {}
    description {
      Less or equal: push (stknext <= stktop)
    }
  }
  ge {
    args {}
    description {
      Greater or equal: push (stknext >= stktop)
    }
  }
  lshift {
    args {}
    description {
      Left shift: push (stknext << stktop)
    }
  }
  rshift {
    args {}
    description {
      Right shift: push (stknext >> stktop)
    }
  }
  add {
    args {}
    description {
      Add: push (stknext + stktop)
    }
  }
  sub {
    args {}
    description {
      Sub: push (stkext - stktop)
    }
  }
  mult {
    args {}
    description {
      Multiply: push (stknext * stktop)
    }
  }
  div {
    args {}
    description {
      Divide: push (stknext / stktop)
    }
  }
  mod {
    args {}
    description {
      Mod: push (stknext % stktop)
    }
  }
  expon {
    args {}
    description {
      Binary exponentiation operator: push (stknext ** stktop)
    }
  }
  uplus {
    args {}
    description {
      Unary plus: push +stktop
    }
  }
  uminus {
    args {}
    description {
      Unary minus: push -stktop
    }
  }
  bitnot {
    args {}
    description {
      Bitwise not: push ~stktop
    }
  }
  not {
    args {}
    description {
      Logical not: push !stktop
    }
  }
  tryCvtToNumeric {
    args {}
    description {
      Try converting stktop to first int then double if possible.
    }
  }
  numericType {
    args {}
    description {
      Pushes the numeric type code of the word at the top of the stack.
    }
    stackaction {... value => ... typeCode}
  }
  tryCvtToBoolean {
    args {}
    description {
      Try converting stktop to boolean if possible. No errors.
    }
    stackaction {... value => ... value isStrictBool}
  }
  foreach_start4 {
    args {AUX4}
    description {
      Initialize execution of a foreach loop. Operand is aux data index of 
      the ForeachInfo structure for the foreach command. OBSOLETE!
    }
  }
  foreach_step4 {
    args {AUX4}
    description {
      "Step" or begin next iteration of foreach loop. Push 0 if to terminate
      loop, else push 1. OBSOLETE!
    }
  }
  foreach_start {
    args {AUX4}
    description {
      Initialize execution of a foreach loop. Operand is aux data index of 
      the ForeachInfo structure for the foreach command. It pushes 2 
      elements which hold runtime params for foreach_step, they are later 
      dropped by foreach_end together with the value lists. 
      
      NOTE: the iterator-tracker and info reference must not be passed to 
      bytecodes that handle normal Tcl values. NOTE that this instruction 
      jumps to the foreach_step instruction paired with it; the stack info 
      below is only nominal.
    }
    stackaction {... listObjs... => ... listObjs... iterTracker info}
  }
  foreach_step {
    args {}
    description {
      "Step" or begin next iteration of foreach loop. Assigns to foreach
      iteration variables. May jump to straight after the foreach_start that
      pushed the iterTracker and info values. MUST be followed immediately
      by a foreach_end.
    }
    stackaction {... listObjs... iterTracker info => ... listObjs... iterTracker info}
  }
  foreach_end {
    args {}
    description {
      Clean up a foreach loop by dropping the info value, the tracker value
      and the lists that were being iterated over.
    }
    stackaction {... listObjs... iterTracker info => ...}
  }
  lmap_collect {
    args {}
    description {
      Appends the value at the top of the stack to the list located on the
      stack the "other side" of the foreach-related values.
    }
    stackaction {... collector listObjs... iterTracker info value => ... collector listObjs... iterTracker info}
  }
  lappendScalar1 {
    args {LVT1}
    description {
      Lappend scalar variable at op1<=255 in frame; value is stktop
    }
  }
  lappendScalar4 {
    args {LVT4}
    description {
      Lappend scalar variable at op1 > 255 in frame; value is stktop
    }
  }
  lappendArray1 {
    args {LVT1}
    description {
      Lappend array element; array at op1<=255, value is top then elem
    }
  }
  lappendArray4 {
    args {LVT4}
    description {
      Lappend array element; array at op1>=256, value is top then elem
    }
  }
  lappendArrayStk {
    args {}
    description {
      Lappend array element; value is stktop, then elem, array names
    }
  }
  lappendStk {
    args {}
    description {
      Lappend general variable; value is stktop, then unparsed name
    }
  }
  lappendList {
    args {LVT4}
    description {
      Lappend list to scalar variable at op4 in frame.
    }
    stackaction {... list => ... listVarContents}
  }
  lappendListArray {
    args {LVT4}
    description {
      Lappend list to array element; array at op4.
    }
    stackaction {... elem list => ... listVarContents}
  }
  lappendListArrayStk {
    args {}
    description {
      Lappend list to array element.
    }
    stackaction {... arrayName elem list => ... listVarContents}
  }
  lappendListStk {
    args {}
    description {
      Lappend list to general variable.
    }
    stackaction {... varName list => ... listVarContents}
  }
  list {
    args {UINT4}
    description {
      List: push (stk1 stk2 ... stktop)
    }
  }
  listIndex {
    args {}
    description {
      List Index: push (listindex stknext stktop)
    }
  }
  listLength {
    args {}
    description {
      List Len: push (listlength stktop)
    }
  }
  lindexMulti {
    args {UINT4}
    description {
      Lindex with generalized args, operand is number of stacked objs used:
      (operand-1) entries from stktop are the indices; then list to process.
    }
  }
  lsetList {
    args {}
    description {
      Four-arg version of lset. stktop is old value; next is new element 
      value, next is the index list; pushes new value
    }
  }
  lsetFlat {
    args {UINT4}
    description {
      Three- or >=5-arg version of lset, operand is number of stacked objs:
      stktop is old value, next is new element value, next come (operand-2)
      indices; pushes the new value.
    }
  }
  listIndexImm {
    args {IDX4}
    description {
      List Index: push (lindex stktop op4)
    }
  }
  listRangeImm {
    args {IDX4 IDX4}
    description {
      List Range: push (lrange stktop op4 op4)
    }
  }
  listIn {
    args {}
    description {
      List containment: push [lsearch stktop stknext]>=0)
    }
  }
  listNotIn {
    args {}
    description {
      List negated containment: push [lsearch stktop stknext]<0)
    }
  }
  listConcat {
    args {}
    description {
      Concatenates the two lists at the top of the stack into a single list
      and pushes that resulting list onto the stack.
    }
    stackaction {... list1 list2 => ... [lconcat list1 list2]}
  }
  concatStk {
    args {UINT4}
    description {
      Wrapper round Tcl_ConcatObj(), used for concat and eval. opnd is 
      number of values to concatenate.
      Operation: push concat(stk1 stk2 ... stktop)
    }
  }
  dictGet {
    args {UINT4}
    description {
      The top op4 words (min 1) are a key path into the dictionary just 
      below the keys on the stack, and all those values are replaced by the
      value read out of that key-path (like dict get).
    }
    stackaction {... dict key1 ... keyN => ... value}
  }
  dictSet {
    args {UINT4 LVT4}
    description {
      Update a dictionary value such that the keys are a path pointing to
      the value. op4#1 = numKeys, op4#2 = LVTindex
    }
    stackaction {... key1 ... keyN value => ... newDict}
  }
  dictUnset {
    args {UINT4 LVT4}
    description {
      Update a dictionary value such that the keys are not a path pointing
      to any value. op4#1 = numKeys, op4#2 = LVTindex
    }
    stackaction {... key1 ... keyN => ... newDict}
  }
  dictIncrImm {
    args {INT4 LVT4}
    description {
      Update a dictionary value such that the value pointed to by key is
      incremented by some value (or set to it if the key isn't in the 
      dictionary at all). op4#1 = incrAmount, op4#2 = LVTindex
    }
    stackaction {... key => ... newDict}
  }
  dictAppend {
    args {LVT4}
    description {
      Update a dictionary value such that the value pointed to by key has
      some value string-concatenated onto it. op4 = LVTindex
    }
    stackaction {... key valueToAppend => ... newDict}
  }
  dictLappend {
    args {LVT4}
    description {
      Update a dictionary value such that the value pointed to by key has
      some value list-appended onto it. op4 = LVTindex
    }
    stackaction {... key valueToAppend => ... newDict}
  }
  dictFirst {
    args {LVT4}
    description {
      Begin iterating over the dictionary, using the local scalar indicated
      by op4 to hold the iterator state. The local scalar should not refer
      to a named variable as the value is not wholly managed correctly.
    }
    stackaction {... dict => ... value key doneBool}
  }
  dictNext {
    args {LVT4}
    description {
      Get the next iteration from the iterator in op4's local scalar.
    }
    stackaction {... => ... value key doneBool}
  }
  dictDone {
    args {LVT4}
    description {
      Terminate the iterator in op4's local scalar. Use unsetScalar instead
      (with 0 for flags).
    }
  }
  dictUpdateStart {
    args {LVT4 AUX4}
    description {
      Create the variables (described in the aux data referred to by the 
      second immediate argument) to mirror the state of the dictionary in
      the variable referred to by the first immediate argument. The list of
      keys (top of the stack, not poppsed) must be the same length as the
      list of variables.
    }
    stackaction {... keyList => ... keyList}
  }
  dictUpdateEnd {
    args {LVT4 AUX4}
    description {
      Reflect the state of local variables (described in the aux data 
      referred to by the second immediate argument) back to the state of the
      dictionary in the variable referred to by the first immediate argument.
      The list of keys (popped from the stack) must be the same length as
      the list of variables.
    }
    stackaction {... keyList => ...}
  }
  dictExpand {
    args {}
    description {
      Probe into a dict and extract it (or a subdict of it) into variables
      with matched names. Produces list of keys bound as result. Part of
      dict with.
    }
    stackaction {... dict path => ... keyList}
  }
  dictRecombineStk {
    args {}
    description {
      Map variable contents back into a dictionary in a variable. Part of
      dict with.
    }
    stackaction {... dictVarName path keyList => ...}
  }
  dictRecombineImm {
    args {LVT4}
    description {
      Map variable contents back into a dictionary in the local variable 
      indicated by the LVT index. Part of dict with.
    }
    stackaction {... path keyList => ...}
  }
  dictExists {
    args {UINT4}
    description {
      The top op4 words (min 1) are a key path into the dictionary just
      below the keys on the stack, and all those values are replaced by a
      boolean indicating whether it is possible to read out a value from
      that key-path (like dict exists).
    }
    stackaction {... dict key1 ... keyN => ... boolean}
  }
  verifyDict {
    args {}
    description {
      Verifies that the word on the top of the stack is a dictionary,
      popping it if it is and throwing an error if it is not.
    }
    stackaction {... value => ...}
  }
  currentNamespace {
    args {}
    description {
      Push the name of the interpreter's current namespace as an object on
      the stack.
    }
  }
  infoLevelNumber {
    args {}
    description {
      Push the stack depth (i.e., info level) of the interpreter as an
      object on the stack.
    }
  }
  infoLevelArgs {
    args {}
    description {
      Push the argument words to a stack depth (i.e., info level <n>) of the
      interpreter as an object on the stack.
    }
    stackaction {... depth => ... argList}
  }
  resolveCmd {
    args {}
    description {
      Resolves the command named on the top of the stack to its fully
      qualified version, or produces the empty string if no such command
      exists. Never generates errors.
    }
    stackaction {... cmdName => ... fullCmdName}
  }
  originCmd {
    args {}
    description {
      Reports which command was the origin (via namespace import chain) of
      the command named on the top of the stack.
    }
    stackaction {... cmdName => ... fullOriginalCmdName}
  }
  coroName {
    args {}
    description {
      Push the name of the interpreter's current coroutine as an object on
      the stack.
    }
  }
  tclooSelf {
    args {}
    description {
      Push the identity of the current TclOO object (i.e., the name of its
      current public access command) on the stack.
    }
  }
  tclooClass {
    args {}
    description {
      Push the class of the TclOO object named at the top of the stack onto
      the stack.
    }
    stackaction {... object => ... class}
  }
  tclooNamespace {
    args {}
    description {
      Push the namespace of the TclOO object named at the top of the stack
      onto the stack.
    }
    stackaction {... object => ... namespace}
  }
  tclooIsObject {
    args {}
    description {
      Push whether the value named at the top of the stack is a TclOO object
      (i.e., a boolean). Can corrupt the interpreter result despite not
      throwing, so not safe for use in a post-exception context.
    }
    stackaction {... value => ... boolean}
  }
  tclooNext {
    args {UINT1}
    description {
      Call the next item on the TclOO call chain, passing opnd arguments
      (min 1, max 255, includes "next"). The result of the invoked method
      implementation will be pushed on the stack in place of the arguments
      (similar to invokeStk).
    }
    stackaction {... "next" arg2 arg3 -- argN => ... result}
  }
  tclooNextClass {
    args {UINT1}
    description {
      Call the following item on the TclOO call chain defined by class
      className, passing opnd arguments (min 2, max 255, includes "nextto"
      and the class name). The result of the invoked method implementation
      will be pushed on the stack in place of the arguments (similar to
      invokeStk).
    }
    stackaction {... "nextto" className arg3 arg4 -- argN => ... result}
  }
  arrayExistsStk {
    args {}
    description {
      Looks up the element on the top of the stack and tests whether it is
      an array. Pushes a boolean describing whether this is the case. Also
      runs the whole-array trace on the named variable, so can throw
      anything.
    }
    stackaction {... varName => ... boolean}
  }
  arrayExistsImm {
    args {UINT4}
    description {
      Looks up the variable indexed by opnd and tests whether it is an
      array. Pushes a boolean describing whether this is the case. Also runs
      the whole-array trace on the named variable, so can throw anything.
    }
    stackaction {... => ... boolean}
  }
  arrayMakeStk {
    args {}
    description {
      Forces the element on the top of the stack to be the name of an array.
    }
    stackaction {... varName => ...}
  }
  arrayMakeImm {
    args {UINT4}
    description {
      Forces the variable indexed by opnd to be an array. Does not touch the
      stack.
    }
  }
}
