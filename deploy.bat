chcp 65001

:: TODO 判断mkdocs环境是否存在，不存在则创建
:: call命令的作用是在批处理脚本中，用来从一个批处理脚本中调用另一个批处理脚本。
:: 调用另一个批处理程序，并且不终止父批处理程序
::（如果不用call而直接调用别的批处理文件，那么执行完那个批处理文件后将无法返回当前文件并执行当前文件的后续命令）
call conda activate mkdocs

:: 部署到github仓库的gh-deploy分支（需要仓库的写入权限）
mkdocs gh-deploy
