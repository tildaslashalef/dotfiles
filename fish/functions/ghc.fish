function ghc --wraps='gh pr view --web' --description 'alias ghc=gh pr view --web'
  gh pr view --web $argv;
end