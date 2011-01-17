(* This is Mathematica code for doing the funny addition. *)
(* Example: add[10,11] gives 11001. *)
(* This is interpreting the numbers as being in base i-1. *)

complextostring[0]=0;
complextostring[n_]:=If[Mod[Re[n],2]==Mod[Im[n],2],10*complextostring[n/(I-1)],10*complextostring[(n-1)/(I-1)]+1]

stringtocomplex[m_]:=FromDigits[IntegerDigits[m],I-1]

add[a_,b_]:=complextostring[stringtocomplex[a]+stringtocomplex[b]]

