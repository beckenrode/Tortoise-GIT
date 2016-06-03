{CompositeDisposable} = require 'atom'
path = require "path"

tortoiseGit = (args, cwd) ->
  spawn = require("child_process").spawn
  command = atom.config.get("tortoise-git.tortoisePath") + "/TortoiseGitProc.exe"
  options =
    cwd: cwd

  tProc = spawn(command, args, options)

  tProc.stdout.on "data", (data) ->
    console.log "stdout: " + data

  tProc.stderr.on "data", (data) ->
    console.log "stderr: " + data

  tProc.on "close", (code) ->
    console.log "child process exited with code " + code

resolveTreeSelection = ->
  if atom.packages.isPackageLoaded("tree-view")
    treeView = atom.packages.getLoadedPackage("tree-view")
    treeView = require(treeView.mainModulePath)
    serialView = treeView.serialize()
    serialView.selectedPath = serialView.selectedPath.replace " ", "%20"
    serialView.selectedPath

resolveTreeRoot = ->
  if atom.packages.isPackageLoaded("tree-view")
    treeView = atom.packages.getLoadedPackage("tree-view")
    treeView = require(treeView.mainModulePath)
    serialView = treeView.serialize()
    rootDir = Object.keys(serialView.directoryExpansionStates)[0]
    rootDir = rootDir.replace " ", "%20"
    rootDir

commit = (currFile)->
  tortoiseGit(["/command:commit", "/path:"+currFile], path.dirname(currFile))

pull = (currFile)->
  tortoiseGit(["/command:pull", "/path:"+currFile], path.dirname(currFile))

push = (currFile)->
  tortoiseGit(["/command:push", "/path:"+currFile], path.dirname(currFile))
  
diff = (currFile)->
  tortoiseGit(["/command:diff", "/path:"+currFile], path.dirname(currFile))
  
log = (currFile)->
  tortoiseGit(["/command:log", "/path:"+currFile], path.dirname(currFile))

checkout = (rootDir)->
  tortoiseGit(["/command:switch", "/path:"+rootDir], rootDir)

module.exports = TortoiseGit =
  config:
    tortoisePath:
      title: "Tortoise GIT bin path"
      description: "The folder containing TortoiseGitProc.exe"
      type: "string"
      default: "C:/Program Files/TortoiseGit/bin"
  tortoiseGitView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    atom.commands.add "atom-workspace", "tortoise-git:pushFromTreeView": => @pushFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-git:pullFromTreeView": => @pullFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-git:commitFromTreeView": => @commitFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-git:diffFromTreeView": => @diffFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-git:logFromTreeView": => @logFromTreeView()
    atom.commands.add "atom-workspace", "tortoise-git:checkoutFromTreeView": => @checkoutFromTreeView()

  pushFromTreeView: ->
    currFile = resolveTreeSelection()
    push(currFile) if currFile?

  pullFromTreeView: ->
    currFile = resolveTreeSelection()
    pull(currFile) if currFile?

  commitFromTreeView: ->
    currFile = resolveTreeSelection()
    commit(currFile) if currFile?

  diffFromTreeView: ->
    currFile = resolveTreeSelection()
    diff(currFile) if currFile?

  logFromTreeView: ->
    currFile = resolveTreeSelection()
    log(currFile) if currFile?

  checkoutFromTreeView: ->
    rootDir = resolveTreeRoot()
    checkout(rootDir) if rootDir?
