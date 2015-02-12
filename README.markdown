# commentary.vim

## initial Version

This is based on the [vim-commentary](https://github.com/tpope/vim-pathogen)
plugin from Tim Pope.

This one is more advanced and toggles comments if they do not have a trailing space.
as no one was interested in this functionality (issues [#3], [#32], [#33] and [#40])

## Description

Comment stuff out.  Use `gcc` to comment out a line (takes a count),
`gc` to comment out the target of a motion (for example, `gcap` to
comment out a paragraph), `gc` in visual mode to comment out the selection,
and `gc` in operator pending mode to target a comment.  You can also use
it as a command, either with a range like `:7,17Commentary`, or as part of a
`:global` invocation like with `:g/TODO/Commentary`. That's it.

Oh, and it uncomments, too.  The above maps actually toggle, and `gcgc`
uncomments a set of adjacent commented lines.

## Installation

If you don't have a preferred installation method, I recommend
installing [pathogen.vim](https://github.com/tpope/vim-pathogen), and
then simply copy and paste:

    cd ~/.vim/bundle
    git clone git://github.com/chrisbra/vim-commentary.git

Once help tags have been generated, you can view the manual with
`:help commentary`.

## FAQ

> My favorite file type isn't supported!

Relax!  You just have to adjust `'commentstring'`:

    autocmd FileType apache set commentstring=#\ %s

## Self-Promotion

Like commentary.vim? Follow the repository on
[GitHub](https://github.com/chrisbra/vim-commentary)

## License

See `:help license`.

[#3](https://github.com/tpope/vim-commentary/issues/3)
[#30](https://github.com/tpope/vim-commentary/issues/30)
[#33](https://github.com/tpope/vim-commentary/issues/33)
[#40](https://github.com/tpope/vim-commentary/issues/40)
