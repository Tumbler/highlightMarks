" @Tracked
" Highlight Marks plugin
" Author: Tumbler Terrall [TumblerTerrall@gmail.com]
" Last Edited: 04/05/2017 01:10 PM
let s:Version = 1.05

" Anti-inclusion guard and version
if (exists("g:loaded_highlightMarks") && (g:loaded_highlightMarks >= s:Version))
   finish
endif
let g:loaded_highlightMarks = s:Version

" Options
if (!exists('g:highlightMarks_colors'))
   " You can define this variable yourself to define what colors you want to
   " use for your highlighting. Takes a list of colors or RGB hex numbers.
   let g:highlightMarks_colors = ['orange', 'yellow', 'green', 'blue', 'purple', '#00BB33']
endif
if (!exists('g:highlightMarks_cterm_colors'))
   " Used for cterm colors. Takes a list of numbers.
   let g:highlightMarks_cterm_colors = [3, 2, 4, 1]
endif
if (!exists('g:highlightMarks_useSigns'))
   " Define this variable as true if you want to highlight line to the end of
   " the screen. Note that this isn't quite as reliable as the other method
   " and brings up an (IMO) ugly column on the left.
   let g:highlightMarks_useSigns = 0
endif

" [script]Global variables
let s:highlights = {}
let s:index = 0
let s:cterm_index = 0
let s:nextID = 1

" Commands
command! -nargs=* RemoveMarkHighlights call <SID>RemoveHighlighting(<f-args>)

" Take control of adding marks
let s:c='A'
while s:c <= 'z'
   if (s:c =~ '\a')
      " Only remap them if they're alphabetical
      exec 'nnoremap <silent>m'.s:c.' :call <SID>AddMark("'.s:c.'")<CR>'
   endif
   let s:c = nr2char(1+char2nr(s:c))
endwhile

" AddMark <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
"   brief: Adds mark like normal but also highlights the line
"     input   - mark: [char] The mark that you want to place
"     returns - void
function! s:AddMark(mark)
   call <SID>HighlightMark(a:mark)
   exe "normal! m". a:mark
endfunction

" HighlightMark <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
"   brief: Highlights the line of the specified mark with colors from
"          g:highlightMarks_colors
"     input   - mark: [char] The mark to highlight
"     returns - void
function! s:HighlightMark(mark)
   " Need to be able to differentiate capitals from lowercases.
   let name = 'highlightMarks_'. ((a:mark =~ '\u') ? 'C'. a:mark :a:mark)
   if (has_key(s:highlights, a:mark) && len(s:highlights[a:mark]) == 2)
      " If mark has been defined before, remove the reference to the highlight,
      " but leave the color intact
      call <SID>MatchDelete(s:highlights[a:mark][1])
      call remove(s:highlights[a:mark], 1)
   elseif (has_key(s:highlights, a:mark))
      " Mark has been defined but removed
      let color = s:highlights[a:mark][0][0]
      let cterm_color = s:highlights[a:mark][0][1]
      exe "highlight ". name ." ctermbg=". cterm_color ." guibg=". color
      if (g:highlightMarks_useSigns)
         exe "sign define ". name ." linehl=". name
      endif
   else
      " Not previously defined
      let color = g:highlightMarks_colors[s:index]
      let cterm_color = g:highlightMarks_cterm_colors[s:cterm_index]
      let s:index = (s:index + 1) % len(g:highlightMarks_colors)
      let s:cterm_index = (s:cterm_index + 1) % len(g:highlightMarks_cterm_colors)
      exe "highlight ". name ." ctermbg=". cterm_color ." guibg=". color
      if (g:highlightMarks_useSigns)
         exe "sign define ". name ." linehl=". name
      endif
      let s:highlights[a:mark] = [[color, cterm_color]]
   endif
   if (g:highlightMarks_useSigns)
      let ID = <SID>GetNextID()
      exe "sign place ". ID ." line=". line('.') ." name=". name ." file=". expand('%:p')
      call add(s:highlights[a:mark], ID)
   else
      call add(s:highlights[a:mark], matchadd(name, ".*\\%'".a:mark.'.*', 0))
   endif
endfunction

" RemoveHighlighting ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
"   brief: Removes the highlighting of the specified mark(s)
"     input   - optional: [[char]] If present, will remove highlighting for all
"               specified marks. If empty, removes highlighting for all marks.
"     returns - void
function! s:RemoveHighlighting(...)
   if (a:0)
      " Only delete highlighting for specified marks
      for mark in a:000
         if (has_key(s:highlights, mark) && len(s:highlights[mark]) > 1)
            call <SID>MatchDelete(s:highlights[mark][1])
            call remove(s:highlights[mark], 1)
         endif
      endfor
   else
      " No arguments, delete all
      for mark in values(s:highlights)
         if (len(mark) > 1)
            call <SID>MatchDelete(mark[1])
            call remove(mark, 1)
         endif
      endfor
   endif
endfunction

" MatchDelete <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
"   brief: Deletes a highlight match, but takes into account weather signs
"          are being used or not.
"     input   - ID: [int] The ID of the match to delete
"     returns - void
function! s:MatchDelete(ID)
   if (g:highlightMarks_useSigns)
      exe "sign unplace ". a:ID
   else
      call matchdelete(a:ID)
   endif
endfunction

" GetNextID <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
"   brief: Finds the next unique ID and returns it
"     returns - The next unique ID
function! s:GetNextID()
   let retVal = s:nextID
   let s:nextID += 1
   return retVal
endfunction

" The MIT License (MIT)
"
" Copyright © 2017 Warren Terrall
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to
" deal in the Software without restriction, including without limitation the
" rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
" sell copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" The software is provided "as is", without warranty of any kind, express or
" implied, including but not limited to the warranties of merchantability,
" fitness for a particular purpose and noninfringement. In no event shall the
" authors or copyright holders be liable for any claim, damages or other
" liability, whether in an action of contract, tort or otherwise, arising
" from, out of or in connection with the software or the use or other dealings
" in the software.
"<< End of Highlight Marks plugin <><><><><><><><><><><><><><><><><><><><><><><>
