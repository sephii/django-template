{ writeShellScriptBin, {{ cookiecutter.project_slug }}, concurrently, dockerTools, tmux, tmux-xpanes }:

{
  # Launch development server
  dev = writeShellScriptBin "dev" ''
    rm -rf ./node_modules
    ln -s {{ '${' }}{{ cookiecutter.project_slug }}.frontend.nodeDependencies}/lib/node_modules ./node_modules
    export PATH="{{ '${' }}{{ cookiecutter.project_slug }}.frontend.nodeDependencies}/bin:$PATH"
    TMUX_XPANES_EXEC=${tmux}/bin/tmux nix develop --command ${tmux-xpanes}/bin/xpanes -d -e "cd backend && python -m django runserver" "cd frontend && npm run dev" ""
  '';
}
