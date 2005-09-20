" Vim completion script
" Language:	CSS 2.1
" Maintainer:	Mikolaj Machowski ( mikmach AT wp DOT pl )
" Last Change:	2005 Sep 19

function! csscomplete#CompleteCSS(findstart, base)
if a:findstart
	" We need whole line to proper checking
	return 0
else
	" There are few chars important for context:
	" ^ ; : { } /* */
	" Where ^ is start of line and /* */ are comment borders
	" Depending on their relative position to cursor we will now what should
	" be completed. 
	" 1. if nearest are ^ or { or ; current word is property
	" 2. if : it is value
	" 3. if } we are outside of css definitions
	" 4. for comments ignoring is be the easiest but assume they are the same
	"    as 1. 
	
	let line = a:base
	let res = []
	let res2 = []
	let borders = {}

	" We need the last occurrence of char so reverse line
	let revline = join(reverse(split(line, '.\zs')), '')
	let openbrace  = stridx(revline, '{')
	let closebrace = stridx(revline, '}')
	let colon       = stridx(revline, ':')
	let semicolon   = stridx(revline, ';')
	let opencomm    = stridx(revline, '*/') " Line was reversed
	let closecomm   = stridx(revline, '/*') " Line was reversed
	let style       = stridx(revline, '=\s*elyts') " Line was reversed
	let atrule      = stridx(revline, '@')

	if openbrace > -1
		let borders[openbrace] = "openbrace"
	endif
	if closebrace > -1
		let borders[closebrace] = "closebrace"
	endif
	if colon > -1
		let borders[colon] = "colon"
	endif
	if semicolon > -1
		let borders[semicolon] = "semicolon"
	endif
	if opencomm > -1
		let borders[opencomm] = "opencomm"
	endif
	if closecomm > -1
		let borders[closecomm] = "closecomm"
	endif
	if style > -1
		let borders[style] = "style"
	endif
	if atrule > -1
		let borders[atrule] = "atrule"
	endif

	if len(borders) == 0 || borders[min(keys(borders))] =~ '^\(openbrace\|semicolon\|opencomm\|closecomm\|style\)$'
		" Complete properties

		let values = split("azimuth background-attachment background-color background-image background-position background-repeat background border-collapse border-color border-spacing border-style border-top border-right border-bottom border-left border-top-color border-right-color border-bottom-color border-left-color  border-top-style border-right-style border-bottom-style border-left-style border-top-width border-right-width border-bottom-width border-left-width border-width border bottom caption-side clear clip color content counter-increment counter-reset cue-after cue-before cue cursor direction display elevation empty-cells float font-family font-size font-style font-variant font-weight font height left letter-spacing line-height list-style-image list-style-position list-style-type list-style margin-right margin-left margin-top margin-bottom max-height max-width min-height min-width orphans outline-color outline-style outline-width outline overflow padding-top padding-right padding-bottom padding-left padding page-break-after page-break-before page-break-inside pause-after pause-before pause pitch-range pitch play-during position quotes richness right speak-header speak-numeral speak-punctuation speak speech-rate stress table-layout text-align text-decoration text-indent text-transform top unicode-bidi vertical-align visibility voice-family volume white-space widows width word-spacing z-index")

		let propbase = matchstr(line, '.\{-}\ze[a-zA-Z-]*$')
		let entered_property = matchstr(line, '.\{-}\zs[a-zA-Z-]*$')

		for m in values
			if m =~? '^'.entered_property
				call add(res, propbase . m.': ')
			elseif m =~? entered_property
				call add(res2, propbase . m.': ')
			endif
		endfor

		return res + res2

	elseif borders[min(keys(borders))] == 'colon'
		" Get name of property
		let prop = tolower(matchstr(line, '\zs[a-zA-Z-]*\ze\s*:[^:]\{-}$'))

		if prop == 'azimuth'
			let values = ["left-side", "far-left", "left", "center-left", "center", "center-right", "right", "far-right", "right-side", "behind", "leftwards", "rightwards"]
		elseif prop == 'background-attachment'
			let values = ["scroll", "fixed"]
		elseif prop == 'background-color'
			let values = ["transparent", "rgb(", "#"]
		elseif prop == 'background-image'
			let values = ["url(", "none"]
		elseif prop == 'background-position'
			let vals = matchstr(line, '.*:\s*\zs.*')
			if vals =~ '^\([a-zA-Z]\+\)\?$'
				let values = ["top", "center", "bottom"]
			elseif vals =~ '^[a-zA-Z]\+\s\+\([a-zA-Z]\+\)\?$'
				let values = ["left", "center", "right"]
			else
				return []
			endif
		elseif prop == 'background-repeat'
			let values = ["repeat", "repeat-x", "repeat-y", "no-repeat"]
		elseif prop == 'background'
			let values = ["url(", "scroll", "fixed", "transparent", "rgb(", "#", "none", "top", "center", "bottom" , "left", "right", "repeat", "repeat-x", "repeat-y", "no-repeat"]
		elseif prop == 'border-collapse'
			let values = ["collapse", "separate"]
		elseif prop == 'border-color'
			let values = ["rgb(", "#", "transparent"]
		elseif prop == 'border-spacing'
			return []
		elseif prop == 'border-style'
			let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
		elseif prop =~ 'border-\(top\|right\|bottom\|left\)$'
			let vals = matchstr(line, '.*:\s*\zs.*')
			if vals =~ '^\([a-zA-Z0-9.]\+\)\?$'
				let values = ["thin", "thick", "medium"]
			elseif vals =~ '^[a-zA-Z0-9.]\+\s\+\([a-zA-Z]\+\)\?$'
				let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
			elseif vals =~ '^[a-zA-Z0-9.]\+\s\+[a-zA-Z]\+\s\+\([a-zA-Z(]\+\)\?$'
				let values = ["rgb(", "#", "transparent"]
			else
				return []
			endif
		elseif prop =~ 'border-\(top\|right\|bottom\|left\)-color'
			let values = ["rgb(", "#", "transparent"]
		elseif prop =~ 'border-\(top\|right\|bottom\|left\)-style'
			let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
		elseif prop =~ 'border-\(top\|right\|bottom\|left\)-width'
			let values = ["thin", "thick", "medium"]
		elseif prop == 'border-width'
			let values = ["thin", "thick", "medium"]
		elseif prop == 'border'
			let vals = matchstr(line, '.*:\s*\zs.*')
			if vals =~ '^\([a-zA-Z0-9.]\+\)\?$'
				let values = ["thin", "thick", "medium"]
			elseif vals =~ '^[a-zA-Z0-9.]\+\s\+\([a-zA-Z]\+\)\?$'
				let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
			elseif vals =~ '^[a-zA-Z0-9.]\+\s\+[a-zA-Z]\+\s\+\([a-zA-Z(]\+\)\?$'
				let values = ["rgb(", "#", "transparent"]
			else
				return []
			endif
		elseif prop == 'bottom'
			let values = ["auto"]
		elseif prop == 'caption-side'
			let values = ["top", "bottom"]
		elseif prop == 'clear'
			let values = ["none", "left", "right", "both"]
		elseif prop == 'clip'
			let values = ["auto", "rect("]
		elseif prop == 'color'
			let values = ["rgb(", "#"]
		elseif prop == 'content'
			let values = ["normal", "attr(", "open-quote", "close-quote", "no-open-quote", "no-close-quote"]
		elseif prop =~ 'counter-\(increment\|reset\)$'
			let values = ["none"]
		elseif prop =~ '^\(cue-after\|cue-before\|cue\)$'
			let values = ["url(", "none"]
		elseif prop == 'cursor'
			let values = ["url(", "auto", "crosshair", "default", "pointer", "move", "e-resize", "ne-resize", "nw-resize", "n-resize", "se-resize", "sw-resize", "s-resize", "w-resize", "text", "wait", "help", "progress"]
		elseif prop == 'direction'
			let values = ["ltr", "rtl"]
		elseif prop == 'display'
			let values = ["inline", "block", "list-item", "run-in", "inline-block", "table", "inline-table", "table-row-group", "table-header-group", "table-footer-group", "table-row", "table-column-group", "table-column", "table-cell", "table-caption", "none"]
		elseif prop == 'elevation'
			let values = ["below", "level", "above", "higher", "lower"]
		elseif prop == 'empty-cells'
			let values = ["show", "hide"]
		elseif prop == 'float'
			let values = ["left", "right", "none"]
		elseif prop == 'font-family'
			let values = ["sans-serif", "serif", "monospace", "cursive", "fantasy"]
		elseif prop == 'font-size'
			return []
		elseif prop == 'font-style'
			let values = ["normal", "italic", "oblique"]
		elseif prop == 'font-variant'
			let values = ["normal", "small-caps"]
		elseif prop == 'font-weight'
			let values = ["normal", "bold", "bolder", "lighter", "100", "200", "300", "400", "500", "600", "700", "800", "900"]
		elseif prop == 'font'
			let values = ["normal", "italic", "oblique", "small-caps", "bold", "bolder", "lighter", "100", "200", "300", "400", "500", "600", "700", "800", "900", "sans-serif", "serif", "monospace", "cursive", "fantasy", "caption", "icon", "menu", "message-box", "small-caption", "status-bar"]
		elseif prop =~ '^\(height\|width\)$'
			let values = ["auto"]
		elseif prop =~ '^\(left\|rigth\)$'
			let values = ["auto"]
		elseif prop == 'letter-spacing'
			let values = ["normal"]
		elseif prop == 'line-height'
			let values = ["normal"]
		elseif prop == 'list-style-image'
			let values = ["url(", "none"]
		elseif prop == 'list-style-position'
			let values = ["inside", "outside"]
		elseif prop == 'list-style-type'
			let values = ["disc", "circle", "square", "decimal", "decimal-leading-zero", "lower-roman", "upper-roman", "lower-latin", "upper-latin", "none"]
		elseif prop == 'list-style'
			return []
		elseif prop == 'margin'
			let values = ["auto"]
		elseif prop =~ 'margin-\(right\|left\|top\|bottom\)$'
			let values = ["auto"]
		elseif prop == 'max-height'
			let values = ["auto"]
		elseif prop == 'max-width'
			let values = ["none"]
		elseif prop == 'min-height'
			let values = ["none"]
		elseif prop == 'min-width'
			let values = ["none"]
		elseif prop == 'orphans'
			return []
		elseif prop == 'outline-color'
			let values = ["rgb(", "#"]
		elseif prop == 'outline-style'
			let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
		elseif prop == 'outline-width'
			let values = ["thin", "thick", "medium"]
		elseif prop == 'outline'
			let vals = matchstr(line, '.*:\s*\zs.*')
			if vals =~ '^\([a-zA-Z0-9,()#]\+\)\?$'
				let values = ["rgb(", "#"]
			elseif vals =~ '^[a-zA-Z0-9,()#]\+\s\+\([a-zA-Z]\+\)\?$'
				let values = ["none", "hidden", "dotted", "dashed", "solid", "double", "groove", "ridge", "inset", "outset"]
			elseif vals =~ '^[a-zA-Z0-9,()#]\+\s\+[a-zA-Z]\+\s\+\([a-zA-Z(]\+\)\?$'
				let values = ["thin", "thick", "medium"]
			else
				return []
			endif
		elseif prop == 'overflow'
			let values = ["visible", "hidden", "scroll", "auto"]
		elseif prop == 'padding'
			return []
		elseif prop =~ 'padding-\(top\|right\|bottom\|left\)$'
			return []
		elseif prop =~ 'page-break-\(after\|before\)$'
			let values = ["auto", "always", "avoid", "left", "right"]
		elseif prop == 'page-break-inside'
			let values = ["auto", "avoid"]
		elseif prop =~ 'pause-\(after\|before\)$'
			return []
		elseif prop == 'pause'
			return []
		elseif prop == 'pitch-range'
			return []
		elseif prop == 'pitch'
			let values = ["x-low", "low", "medium", "high", "x-high"]
		elseif prop == 'play-during'
			let values = ["url(", "mix", "repeat", "auto", "none"]
		elseif prop == 'position'
			let values = ["static", "relative", "absolute", "fixed"]
		elseif prop == 'quotes'
			let values = ["none"]
		elseif prop == 'richness'
			return []
		elseif prop == 'speak-header'
			let values = ["once", "always"]
		elseif prop == 'speak-numeral'
			let values = ["digits", "continuous"]
		elseif prop == 'speak-punctuation'
			let values = ["code", "none"]
		elseif prop == 'speak'
			let values = ["normal", "none", "spell-out"]
		elseif prop == 'speech-rate'
			let values = ["x-slow", "slow", "medium", "fast", "x-fast", "faster", "slower"]
		elseif prop == 'stress'
			return []
		elseif prop == 'table-layout'
			let values = ["auto", "fixed"]
		elseif prop == 'text-align'
			let values = ["left", "right", "center", "justify"]
		elseif prop == 'text-decoration'
			let values = ["none", "underline", "overline", "line-through", "blink"]
		elseif prop == 'text-indent'
			return []
		elseif prop == 'text-transform'
			let values = ["capitalize", "uppercase", "lowercase", "none"]
		elseif prop == 'top'
			let values = ["auto"]
		elseif prop == 'unicode-bidi'
			let values = ["normal", "embed", "bidi-override"]
		elseif prop == 'vertical-align'
			let values = ["baseline", "sub", "super", "top", "text-top", "middle", "bottom", "text-bottom"]
		elseif prop == 'visibility'
			let values = ["visible", "hidden", "collapse"]
		elseif prop == 'voice-family'
			return []
		elseif prop == 'volume'
			let values = ["silent", "x-soft", "soft", "medium", "loud", "x-loud"]
		elseif prop == 'white-space'
			let values = ["normal", "pre", "nowrap", "pre-wrap", "pre-line"]
		elseif prop == 'widows'
			return []
		elseif prop == 'word-spacing'
			let values = ["normal"]
		elseif prop == 'z-index'
			let values = ["auto"]
		else
			return []
		endif

		" Complete values
		let valbase = matchstr(line, '.\{-}\ze[a-zA-Z0-9#,.(_-]*$')
		let entered_value = matchstr(line, '.\{-}\zs[a-zA-Z0-9#,.(_-]*$')

		for m in values
			if m =~? '^'.entered_value
				call add(res, valbase . m)
			elseif m =~? entered_value
				call add(res2, valbase . m)
			endif
		endfor

		return res + res2

	elseif borders[min(keys(borders))] == 'closebrace'

		return []

	elseif borders[min(keys(borders))] == 'atrule'

		let afterat = matchstr(line, '.*@\zs.*')

		if afterat =~ '\s'

			let atrulename = matchstr(line, '.*@\zs[a-zA-Z-]\+\ze')

			if atrulename == 'media'
				let values = ["screen", "tty", "tv", "projection", "handheld", "print", "braille", "aural", "all"]

				let atruleafterbase = matchstr(line, '.*@media\s\+\ze.*$')
				let entered_atruleafter = matchstr(line, '.*@media\s\+\zs.*$')

			elseif atrulename == 'import'
				let atruleafterbase = matchstr(line, '.*@import\s\+\ze.*$')
				let entered_atruleafter = matchstr(line, '.*@import\s\+\zs.*$')

				if entered_atruleafter =~ "^[\"']"
					let filestart = matchstr(entered_atruleafter, '^.\zs.*')
					let files = split(glob(filestart.'*'), '\n')
					let values = map(copy(files), '"\"".v:val')

				elseif entered_atruleafter =~ "^url("
					let filestart = matchstr(entered_atruleafter, "^url([\"']\\?\\zs.*")
					let files = split(glob(filestart.'*'), '\n')
					let values = map(copy(files), '"url(".v:val')
					
				else
					let values = ['"', 'url(']

				endif

			else
				return []

			endif

			for m in values
				if m =~? '^'.entered_atruleafter
					call add(res, atruleafterbase . m)
				elseif m =~? entered_atruleafter
					call add(res2, atruleafterbase . m)
				endif
			endfor

			return res + res2

		endif

		let values = ["charset", "page", "media", "import"]

		let atrulebase = matchstr(line, '.*@\ze[a-zA-Z -]*$')
		let entered_atrule = matchstr(line, '.*@\zs[a-zA-Z-]*$')

		for m in values
			if m =~? '^'.entered_atrule
				call add(res, atrulebase . m.' ')
			elseif m =~? entered_atrule
				call add(res2, atrulebase . m.' ')
			endif
		endfor

		return res + res2

	endif

	return []

	endif
endfunction
