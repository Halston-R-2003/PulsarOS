;; Utility macros

%macro STRING 2
	%1 db %2, 0
	%1_len equ $ - %1 - 1
%endmacro
