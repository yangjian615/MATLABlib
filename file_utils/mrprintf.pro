; docformat = 'rst'
;
; NAME:
;    MrPrintF
;
;*****************************************************************************************
;   Copyright (c) 2015, Matthew Argall                                                   ;
;   All rights reserved.                                                                 ;
;                                                                                        ;
;   Redistribution and use in source and binary forms, with or without modification,     ;
;   are permitted provided that the following conditions are met:                        ;
;                                                                                        ;
;       * Redistributions of source code must retain the above copyright notice,         ;
;         this list of conditions and the following disclaimer.                          ;
;       * Redistributions in binary form must reproduce the above copyright notice,      ;
;         this list of conditions and the following disclaimer in the documentation      ;
;         and/or other materials provided with the distribution.                         ;
;       * Neither the name of the University of New Hampshire nor the names of its       ;
;         contributors may be used to endorse or promote products derived from this      ;
;         software without specific prior written permission.                            ;
;                                                                                        ;
;   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY  ;
;   EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES ;
;   OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT  ;
;   SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,       ;
;   INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED ;
;   TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR   ;
;   BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN     ;
;   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN   ;
;   ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH  ;
;   DAMAGE.                                                                              ;
;*****************************************************************************************
;
; PURPOSE:
;+
;   A wrapper for IDL's PrintF procedure that can direct output to standard output,
;   error, or log files.
;
; :Categories:
;    File Utility
;
; :Params:
;       LUN:        in, optional, type=string
;                   Logical unit number of the destination file. Special LUNs include::
;                       'stdout'    - File associated with standard output (MrStdOut)
;                       '<stdout>'  - File associated with standard output (MrStdOut)
;                       'stdout'    - File associated with standard error (MrStdErr)
;                       '<stdout>'  - File associated with standard error (MrStdErr)
;                       'stdlog'    - Add an error message to the Standard log file (MrStdLog)
;                       'logwarn'   - Add an warning message to the Standard log file (MrStdLog)
;                       'logout'    - Add text to the Standard log file (MrStdLog)
;                       'logtext'   - Add text to the Standard log file (MrStdLog)
;                   If one of the above is given, ARG2-20 are ignored.
;       ARG2-20:    in, optional, type=any
;                   Up to 20 additional expressions to be output. See IDL's PrintF
;                       procedure for details.
;
; :Keywords:
;       FORMAT:     in, optional, type=string
;                   Allows the format of the output to be specified in precise detail,
;                       using a FORTRAN-style specification. If is not specified,
;                       IDL uses its default rules for formatting the output.
;       _REF_EXTRA: in, optional, type=any
;                   Any other keyword (includeing FORMAT) accepted by IDL's PrintF procedure.
;
; :See Also:
;   MrStdErr, MrStdOut, MrStdLog, MrLogFile__Define
;
; :Author:
;    Matthew Argall::
;        University of New Hampshire
;        Morse Hall Room 348
;        8 College Road
;        Durham, NH 03824
;        matthew.argall@unh.edu
;
; :History:
;    Modification History::
;       2015/10/29  -   Written by Matthew Argall
;-
pro MrPrintF, lun,  arg1,  arg2,  arg3,  arg4,  arg5,  arg6,  arg7,  arg8,  arg9, arg10, $
                   arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, $
FORMAT=format, $
_REF_EXTRA=ref_extra
	compile_opt idl2
	on_error, 2
	
	;Number of consecutive parameters with more than 0 elements
	nparams = n_elements(arg1)      eq 0 ?  0 : $
	              n_elements(arg2)  eq 0 ?  1 : $
	              n_elements(arg3)  eq 0 ?  2 : $
	              n_elements(arg4)  eq 0 ?  3 : $
	              n_elements(arg5)  eq 0 ?  4 : $
	              n_elements(arg6)  eq 0 ?  5 : $
	              n_elements(arg7)  eq 0 ?  6 : $
	              n_elements(arg8)  eq 0 ?  7 : $
	              n_elements(arg9)  eq 0 ?  8 : $
	              n_elements(arg10) eq 0 ?  9 : $
	              n_elements(arg11) eq 0 ? 10 : $
	              n_elements(arg12) eq 0 ? 11 : $
	              n_elements(arg13) eq 0 ? 12 : $
	              n_elements(arg14) eq 0 ? 13 : $
	              n_elements(arg15) eq 0 ? 14 : $
	              n_elements(arg16) eq 0 ? 15 : $
	              n_elements(arg17) eq 0 ? 16 : $
	              n_elements(arg18) eq 0 ? 17 : $
	              n_elements(arg19) eq 0 ? 18 : $
	              n_elements(arg20) eq 0 ? 19 : $
	              20

;-----------------------------------------------------
; STDOUT, STDERR, STDLOG, ETC. \\\\\\\\\\\\\\\\\\\\\\\
;-----------------------------------------------------
	if size(lun, /TNAME) eq 'STRING' then begin
		if nparams ne 2 then message, 'Incorrect number of parameters.'
	
		;Pick the output method.
		case strlowcase(lun) of
			'stdout':   theLUN = MrStdOut()
			'<stdout>': theLUN = MrStdOut()
			'stderr':   theLUN = MrStdErr()
			'<stderr>': theLUN = MrStdErr()
			'stdlog': BEGIN
				oLog = MrStdLog()
				oLog -> AddError, arg1
			ENDCASE
			'logerr': BEGIN
				oLog = MrStdLog()
				oLog -> AddError, arg1
			ENDCASE
			'logwarn': BEGIN
				oLog = MrStdLog()
				oLog -> AddWarning, arg1
			ENDCASE
			'logout': BEGIN
				oLog = MrStdLog()
				oLog -> AddText, arg1
			ENDCASE
			'logtext': BEGIN
				oLog = MrStdLog()
				oLog -> AddText, arg1
			ENDCASE
			else: message, 'Invalid value for LUN: "' + lun + '".'
		endcase
	endif else begin
		theLUN = lun
	endelse
	
	;Print to file
	if n_elements(theLUN) gt 0 then begin
		case nparams of
			20: printf, theLUN,  arg1,  arg2,  arg3,  arg4,  arg5,  arg6,  arg7,  arg8,  arg9, arg10, $
			                    arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			19: printf, theLUN,  arg1,  arg2,  arg3,  arg4,  arg5,  arg6,  arg7,  arg8,  arg9, arg10, $
			                    arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			18: printf, theLUN,  arg1,  arg2,  arg3,  arg4,  arg5,  arg6,  arg7,  arg8,  arg9, arg10, $
			                    arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			17: printf, theLUN,  arg1,  arg2,  arg3,  arg4,  arg5,  arg6,  arg7,  arg8,  arg9, arg10, $
			                    arg11, arg12, arg13, arg14, arg15, arg16, arg17, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			16: printf, theLUN,  arg1,  arg2,  arg3,  arg4,  arg5,  arg6,  arg7,  arg8,  arg9, arg10, $
			                    arg11, arg12, arg13, arg14, arg15, arg16, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			15: printf, theLUN,  arg1,  arg2,  arg3,  arg4,  arg5,  arg6,  arg7,  arg8,  arg9, arg10, $
			                    arg11, arg12, arg13, arg14, arg15, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			14: printf, theLUN,  arg1,  arg2,  arg3,  arg4,  arg5,  arg6,  arg7,  arg8,  arg9, arg10, $
			                    arg11, arg12, arg13, arg14, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			13: printf, theLUN,  arg1,  arg2,  arg3,  arg4,  arg5,  arg6,  arg7,  arg8,  arg9, arg10, $
			                    arg11, arg12, arg13, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			12: printf, theLUN,  arg1,  arg2,  arg3,  arg4,  arg5,  arg6,  arg7,  arg8,  arg9, arg10, $
			                    arg11, arg12, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			11: printf, theLUN,  arg1,  arg2,  arg3,  arg4,  arg5,  arg6,  arg7,  arg8,  arg9, arg10, $
			                    arg11, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			10: printf, theLUN,  arg1,  arg2,  arg3,  arg4,  arg5,  arg6,  arg7,  arg8,  arg9, arg10, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			 9: printf, theLUN,  arg1,  arg2,  arg3,  arg4,  arg5,  arg6,  arg7,  arg8,  arg9, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			 8: printf, theLUN,  arg1,  arg2,  arg3,  arg4,  arg5,  arg6,  arg7,  arg8, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			 7: printf, theLUN,  arg1,  arg2,  arg3,  arg4,  arg5,  arg6,  arg7, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			 6: printf, theLUN,  arg1,  arg2,  arg3,  arg4,  arg5,  arg6, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			 5: printf, theLUN,  arg1,  arg2,  arg3,  arg4,  arg5, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			 4: printf, theLUN,  arg1,  arg2,  arg3,  arg4, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			 3: printf, theLUN,  arg1,  arg2,  arg3, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			 2: printf, theLUN,  arg1,  arg2, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			 1: printf, theLUN,  arg1, $
			                    FORMAT=format, _STRICT_EXTRA=extra
			else: message, 'Incorrect number of parameters.'
		endcase
	endif
end