(* This is Mathematica code for doing the five operations. *)
(* They are called add, sub, mult, div, exp. *)

(* Example: add["10","11"] gives the string "11001". *)
(* This is interpreting the numbers as being in base i-1. *)

(* Example: sub["01011","011"] gives the string "00011". *)
(* Note: The quotation marks are necessary, to distinguish 011 from 11,
  for instance *)


stringtolist[str_]:=ToCharacterCode[str]-48
listtostring[list_]:=FromCharacterCode[list+48]
base10tolist[base_]:=IntegerDigits[base]

complextobase10[0]=0;
complextobase10[n_]:=If[Mod[Re[n],2]==Mod[Im[n],2],10*complextobase10[n/(I-1)],10*complextobase10[(n-1)/(I-1)]+1]
complextostring[n_]:=ToString[complextobase10[n]]

stringtocomplex[m_]:=FromDigits[IntegerDigits[ToExpression[m]],I-1]

add[a_,b_]:=complextostring[stringtocomplex[a]+stringtocomplex[b]]



stringtofibonacci[str_]:=Module[{list=stringtolist[str]},Sum[Fibonacci[i+1]*list[[i]],{i,Length[list]-1}]]

largestfibonacci[n_]:=Module[{r=0},While[Fibonacci[r]<=n,++r];r-1]

fibonaccitostringtemp[0]=0;
fibonaccitostringtemp[n_]:=Module[{r=largestfibonacci[n]},10^(r-2)+fibonaccitostringtemp[n-Fibonacci[r]]]

fibonaccitostring[n_]:=listtostring[Append[Reverse[IntegerDigits[fibonaccitostringtemp[n]]],1]]

sub[a_,b_]:=fibonaccitostring[stringtofibonacci[a]-stringtofibonacci[b]]



stringtobaseminus2[str_]:=FromDigits[IntegerDigits[ToExpression[str]],-2]
baseminus2tostring[m_]:=Module[{r=0,s},While[stringtobaseminus2[ToString[FromDigits[IntegerDigits[r,2]]]]!=m,++r];ToString[FromDigits[IntegerDigits[r,2]]]]

mult[a_,b_]:=baseminus2tostring[stringtobaseminus2[a]*stringtobaseminus2[b]]



stringtobase2[str_]:=FromDigits[IntegerDigits[ToExpression[str]],2]
base2tostring[m_]:=ToString[FromDigits[IntegerDigits[m,2]]]

exp[a_,b_]:=base2tostring[stringtobase2[a]^stringtobase2[b]]



stringtobif[str_]:=Module[{list=Reverse[stringtolist[str]]},Sum[(-1)^(i+1)*Fibonacci[i]*list[[i]],{i,Length[list]}]]
biftostring[m_]:=Module[{r=0,s},While[stringtobif[ToString[FromDigits[IntegerDigits[r,2]]]]!=m,++r];ToString[FromDigits[IntegerDigits[r,2]]]]

div[a_,b_]:=biftostring[stringtobif[a]/stringtobif[b]]

