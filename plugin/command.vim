
if exists("g:loaded_command")
	finish
endif
let g:loaded_command=1

command -nargs=1 Cmd :call RunCommand(<f-args>, 0)
command -nargs=1 Cmdc :call RunCommand(<f-args>, 1)
command -nargs=1 Cmde :call RunCommand(<f-args>, 2)
command -nargs=1 Mvn :call RunMvnCommand(<f-args>,0)
command -nargs=1 Mvnc :call RunMvnCommand(<f-args>,1)
command -nargs=1 Mvne :call RunMvnCommand(<f-args>,2)
command -nargs=1 Git :call RunGitCommand(<f-args>,0)
command -nargs=1 Gitc :call RunGitCommand(<f-args>,1)
command -nargs=1 Gite :call RunGitCommand(<f-args>,2)

function RunGitCommand(cmd,mode)
	if !exists("b:gpath")
		call GitStamp()
	endif
	if b:gpath=="null"
		echo "Git path is null."
	else
		call RunCommand("git -C ".b:gpath." ".a:cmd,a:mode)
	endif
endfunction

function GitStamp()
py3 << EOF
import os
path=os.getcwd()
vim.command("let b:gpath='null'")
while len(path)!=0:
	if os.path.exists(path+"/.git"):
		vim.command("let b:gpath='"+path+"'")
		break
	else:
		path=path[:path.rfind("/")]
EOF
endfunction

function RunMvnCommand(cmd,mode)
	if !exists("b:mpath")
		call MavenStamp()
	endif
	if b:mpath=="null"
		echo "Maven path is null."
	else
		call RunCommand("mvn -f ".b:mpath."/pom.xml ".a:cmd,a:mode)
	endif
endfunction

function MavenStamp()
py3 << EOF
import os
curpath=os.getcwd()
if os.path.exists(curpath+"/pom.xml"):
	vim.command("let b:mpath='"+curpath+"'")
else:
	srcidx=(curpath+"/").rfind("/src/")
	if srcidx>=0 and os.path.exists(curpath[:srcidx]+"/pom.xml"):
		vim.command("let b:mpath='"+curpath[:srcidx]+"'")
	else
		vim.command("let b:mpath='null'")
EOF
endfunction

function RunCommand(cmd,mode)
	if a:mode==0
		exec "term ++rows=10 ".a:cmd
	elseif a:mode==1
		exec "term ++curwin ".a:cmd
	elseif a:mode==2
		exec "!".a:cmd
	endif
	set nonumber
endfunction
