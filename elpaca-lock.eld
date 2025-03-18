((denote :source #1="elpaca-menu-lock-file" :recipe
         (:package "denote" :repo
                   ("https://github.com/protesilaos/denote" . "denote") :files
                   ("*" (:exclude ".git" "COPYING" "doclicense.texi")) :source
                   "GNU ELPA" :protocol https :inherit t :depth treeless :ref
                   "3bb05f212cc29fa6953e6d703e5e0c2e982882a9"))
 (tablist :source #1# :recipe
          (:package "tablist" :fetcher github :repo "emacsorphanage/tablist"
                    :files
                    ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                     "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                     "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                     "docs/*.texinfo"
                     (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el"
                               "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
                    :source "MELPA" :protocol https :inherit t :depth treeless
                    :ref "fcd37147121fabdf003a70279cf86fbe08cfac6f"))
 (request :source #1#
   :recipe
   (:package "request" :repo "tkf/emacs-request" :fetcher github :files
             ("request.el") :source "MELPA" :protocol https :inherit t :depth
             treeless :ref "c22e3c23a6dd90f64be536e176ea0ed6113a5ba6"))
 (magit-popup :source #1# :recipe
              (:package "magit-popup" :fetcher github :repo "magit/magit-popup"
                        :files
                        ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                         "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                         "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                         "docs/*.texinfo"
                         (:exclude ".dir-locals.el" "test.el" "tests.el"
                                   "*-test.el" "*-tests.el" "LICENSE" "README*"
                                   "*-pkg.el"))
                        :source "MELPA" :protocol https :inherit t :depth
                        treeless :ref "d8585fa39f88956963d877b921322530257ba9f5"))
 (websocket :source #1# :recipe
            (:package "websocket" :repo "ahyatt/emacs-websocket" :fetcher github
                      :files
                      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                       "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                       "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                       "docs/*.texinfo"
                       (:exclude ".dir-locals.el" "test.el" "tests.el"
                                 "*-test.el" "*-tests.el" "LICENSE" "README*"
                                 "*-pkg.el"))
                      :source "MELPA" :protocol https :inherit t :depth treeless
                      :ref "40c208eaab99999d7c1e4bea883648da24c03be3"))
 (simple-httpd :source #1# :recipe
               (:package "simple-httpd" :repo "skeeto/emacs-web-server" :fetcher
                         github :files
                         ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                          "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                          "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                          "docs/*.texinfo"
                          (:exclude ".dir-locals.el" "test.el" "tests.el"
                                    "*-test.el" "*-tests.el" "LICENSE" "README*"
                                    "*-pkg.el"))
                         :source "MELPA" :protocol https :inherit t :depth
                         treeless :ref
                         "3982c55e9061475038a3ccd61aecb2de3d407cec"))
 (zmq :source #1# :recipe
      (:package "zmq" :fetcher github :repo "nnicandro/emacs-zmq" :files
                (:defaults "Makefile" "src") :source "MELPA" :protocol https
                :inherit t :depth treeless :ref
                "fe856c43286674aa6770d95a81d915363f5df399"))
 (json-snatcher :source #1# :recipe
                (:package "json-snatcher" :fetcher github :repo
                          "Sterlingg/json-snatcher" :files
                          ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                           "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                           "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                           "docs/*.texinfo"
                           (:exclude ".dir-locals.el" "test.el" "tests.el"
                                     "*-test.el" "*-tests.el" "LICENSE"
                                     "README*" "*-pkg.el"))
                          :source "MELPA" :protocol https :inherit t :depth
                          treeless :ref
                          "b28d1c0670636da6db508d03872d96ffddbc10f2"))
 (org-ml :source #1# :recipe
         (:package "org-ml" :repo "ndwarshuis/org-ml" :fetcher github :files
                   ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                    "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                    "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                    "docs/*.texinfo"
                    (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el"
                              "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
                   :source "MELPA" :protocol https :inherit t :depth treeless
                   :ref "f57336a9126a168ad32ccce017c072474555395a"))
 (shell-maker :source #1# :recipe
              (:package "shell-maker" :fetcher github :repo
                        "xenodium/shell-maker" :files
                        ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                         "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                         "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                         "docs/*.texinfo"
                         (:exclude ".dir-locals.el" "test.el" "tests.el"
                                   "*-test.el" "*-tests.el" "LICENSE" "README*"
                                   "*-pkg.el"))
                        :source "MELPA" :protocol https :inherit t :depth
                        treeless :ref "98780ec0a8ac4fe1d6be9e2f8047195cdfad5f70"))
 (with-editor :source #1#
   :recipe
   (:package "with-editor" :fetcher github :repo "magit/with-editor" :files
             ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir"
              "doc/*.info" "doc/*.texi" "doc/*.texinfo" "lisp/*.el" "docs/dir"
              "docs/*.info" "docs/*.texi" "docs/*.texinfo"
              (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el"
                        "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
             :source "MELPA" :protocol https :inherit t :depth treeless :ref
             "ca902ae02972bdd6919a902be2593d8cb6bd991b"))
 (magit-section :source #1# :recipe
                (:package "magit-section" :fetcher github :repo "magit/magit"
                          :files
                          ("lisp/magit-section.el" "docs/magit-section.texi"
                           "magit-section-pkg.el")
                          :source "MELPA" :protocol https :inherit t :depth
                          treeless :ref
                          "f593e8dc8784d772b49284bf5cffaf52ceea6f81"))
 (llama :source #1# :recipe
        (:package "llama" :fetcher github :repo "tarsius/llama" :files
                  ("llama.el" ".dir-locals.el") :source "MELPA" :protocol https
                  :inherit t :depth treeless :ref
                  "48e5bc4919a4a29665362832d59ade8e248b0c3e"))
 (lv :source #1# :recipe
     (:package "lv" :repo "abo-abo/hydra" :fetcher github :files ("lv.el")
               :source "MELPA" :protocol https :inherit t :depth treeless :ref
               "59a2a45a35027948476d1d7751b0f0215b1e61aa"))
 (posframe :source #1# :recipe
           (:package "posframe" :fetcher github :repo "tumashu/posframe" :files
                     ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                      "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                      "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                      "docs/*.texinfo"
                      (:exclude ".dir-locals.el" "test.el" "tests.el"
                                "*-test.el" "*-tests.el" "LICENSE" "README*"
                                "*-pkg.el"))
                     :source "MELPA" :protocol https :inherit t :depth treeless
                     :ref "12f540c9ad5da09673b2bca1132b41f94c134e82"))
 (cfrs :source #1# :recipe
       (:package "cfrs" :repo "Alexander-Miller/cfrs" :fetcher github :files
                 ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir"
                  "doc/*.info" "doc/*.texi" "doc/*.texinfo" "lisp/*.el"
                  "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
                  (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el"
                            "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
                 :source "MELPA" :protocol https :inherit t :depth treeless :ref
                 "f3a21f237b2a54e6b9f8a420a9da42b4f0a63121"))
 (ht :source #1# :recipe
     (:package "ht" :fetcher github :repo "Wilfred/ht.el" :files
               ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir"
                "doc/*.info" "doc/*.texi" "doc/*.texinfo" "lisp/*.el" "docs/dir"
                "docs/*.info" "docs/*.texi" "docs/*.texinfo"
                (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el"
                          "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
               :source "MELPA" :protocol https :inherit t :depth treeless :ref
               "1c49aad1c820c86f7ee35bf9fff8429502f60fef"))
 (hydra :source #1# :recipe
        (:package "hydra" :repo "abo-abo/hydra" :fetcher github :files
                  (:defaults (:exclude "lv.el")) :source "MELPA" :protocol https
                  :inherit t :depth treeless :ref
                  "59a2a45a35027948476d1d7751b0f0215b1e61aa"))
 (pfuture :source #1# :recipe
          (:package "pfuture" :repo "Alexander-Miller/pfuture" :fetcher github
                    :files
                    ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                     "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                     "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                     "docs/*.texinfo"
                     (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el"
                               "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
                    :source "MELPA" :protocol https :inherit t :depth treeless
                    :ref "19b53aebbc0f2da31de6326c495038901bffb73c"))
 (org-agenda-property :source #1# :recipe
                      (:package "org-agenda-property" :repo
                                "Malabarba/org-agenda-property" :fetcher github
                                :files
                                ("*.el" "*.el.in" "dir" "*.info" "*.texi"
                                 "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi"
                                 "doc/*.texinfo" "lisp/*.el" "docs/dir"
                                 "docs/*.info" "docs/*.texi" "docs/*.texinfo"
                                 (:exclude ".dir-locals.el" "test.el" "tests.el"
                                           "*-test.el" "*-tests.el" "LICENSE"
                                           "README*" "*-pkg.el"))
                                :source "MELPA" :protocol https :inherit t
                                :depth treeless :ref
                                "3b469f3e93de0036547f3631cd0366d53f7584c8"))
 (org-edna :source #1# :recipe
           (:package "org-edna" :repo
                     ("https://git.savannah.gnu.org/git/emacs/elpa.git"
                      . "org-edna")
                     :branch "externals/org-edna" :files ("*" (:exclude ".git"))
                     :source "GNU ELPA" :protocol https :inherit t :depth
                     treeless :ref "8258a4dfa00aa522249cdf9aeea5be4de97bd7c1"))
 (org-jira :source #1# :recipe
           (:package "org-jira" :fetcher github :repo "ahungry/org-jira" :files
                     ("jiralib.el" "org-jira.el" "org-jira-sdk.el") :source
                     "MELPA" :protocol https :inherit t :depth treeless :ref
                     "bd61cceeff59617e770e099eae38dd28163bfe76"))
 (jira :source #1# :recipe
       (:source nil :protocol https :inherit t :depth treeless :host github
                :repo "unmonoqueteclea/jira.el" :package "jira" :ref
                "7d0e3e8c76fde3971d9c46b5b06acaecc52fc2ea"))
 (elfeed-webkit :source #1# :recipe
                (:package "elfeed-webkit" :fetcher github :repo
                          "fritzgrabo/elfeed-webkit" :files
                          ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                           "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                           "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                           "docs/*.texinfo"
                           (:exclude ".dir-locals.el" "test.el" "tests.el"
                                     "*-test.el" "*-tests.el" "LICENSE"
                                     "README*" "*-pkg.el"))
                          :source "MELPA" :protocol https :inherit t :depth
                          treeless :ref
                          "db7ee83f9c0e67f01960b1e0489717cf7a8fd2c2"))
 (elfeed-protocol :source #1# :recipe
                  (:package "elfeed-protocol" :repo "fasheng/elfeed-protocol"
                            :fetcher github :files
                            ("*.el" "*.el.in" "dir" "*.info" "*.texi"
                             "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi"
                             "doc/*.texinfo" "lisp/*.el" "docs/dir"
                             "docs/*.info" "docs/*.texi" "docs/*.texinfo"
                             (:exclude ".dir-locals.el" "test.el" "tests.el"
                                       "*-test.el" "*-tests.el" "LICENSE"
                                       "README*" "*-pkg.el"))
                            :source "MELPA" :protocol https :inherit t :depth
                            treeless :ref
                            "4f5e77a28c501db686ac06a2ea250a7b37d5420c"))
 (elfeed :source #1# :recipe
         (:package "elfeed" :repo "skeeto/elfeed" :fetcher github :files
                   (:defaults "README.md") :source "MELPA" :protocol https
                   :inherit t :depth treeless :ref
                   "a39fb78e34ee25dc8baea83376f929d7c128344f"))
 (kubernetes-evil :source #1# :recipe
                  (:package "kubernetes-evil" :repo
                            "kubernetes-el/kubernetes-el" :fetcher github :files
                            ("kubernetes-evil.el") :source "MELPA" :protocol
                            https :inherit t :depth treeless :ref
                            "a9dcf6bbb717dd7a292f21b7e05fe51e4501790a"))
 (kubernetes :source #1# :recipe
             (:package "kubernetes" :repo "kubernetes-el/kubernetes-el" :fetcher
                       github :files (:defaults (:exclude "kubernetes-evil.el"))
                       :source "MELPA" :protocol https :inherit t :depth
                       treeless :ref "a9dcf6bbb717dd7a292f21b7e05fe51e4501790a"))
 (yaml-mode :source #1# :recipe
            (:package "yaml-mode" :repo "yoshiki/yaml-mode" :fetcher github
                      :files
                      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                       "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                       "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                       "docs/*.texinfo"
                       (:exclude ".dir-locals.el" "test.el" "tests.el"
                                 "*-test.el" "*-tests.el" "LICENSE" "README*"
                                 "*-pkg.el"))
                      :source "MELPA" :protocol https :inherit t :depth treeless
                      :ref "d91f878729312a6beed77e6637c60497c5786efa"))
 (dockerfile-mode :source #1# :recipe
                  (:package "dockerfile-mode" :fetcher github :repo
                            "spotify/dockerfile-mode" :files
                            ("*.el" "*.el.in" "dir" "*.info" "*.texi"
                             "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi"
                             "doc/*.texinfo" "lisp/*.el" "docs/dir"
                             "docs/*.info" "docs/*.texi" "docs/*.texinfo"
                             (:exclude ".dir-locals.el" "test.el" "tests.el"
                                       "*-test.el" "*-tests.el" "LICENSE"
                                       "README*" "*-pkg.el"))
                            :source "MELPA" :protocol https :inherit t :depth
                            treeless :ref
                            "8135740bfc6ad96ab82d39d9fe68dbce56180f4c"))
 (elixir-mode :source #1# :recipe
              (:package "elixir-mode" :fetcher github :repo
                        "elixir-editors/emacs-elixir" :files
                        ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                         "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                         "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                         "docs/*.texinfo"
                         (:exclude ".dir-locals.el" "test.el" "tests.el"
                                   "*-test.el" "*-tests.el" "LICENSE" "README*"
                                   "*-pkg.el"))
                        :source "MELPA" :protocol https :inherit t :depth
                        treeless :ref "00d6580a040a750e019218f9392cf9a4c2dac23a"))
 (yasnippet :source #1# :recipe
            (:package "yasnippet" :repo "joaotavora/yasnippet" :fetcher github
                      :files ("yasnippet.el" "snippets") :source "MELPA"
                      :protocol https :inherit t :depth treeless :ref
                      "5b315f1753480ebe669b157b8242448b5eafcfea"))
 (jupyter :source #1# :recipe
          (:package "jupyter" :fetcher github :repo "emacs-jupyter/jupyter"
                    :files (:defaults "Makefile" "widget.html" "js") :source
                    "MELPA" :protocol https :inherit t :depth treeless :ref
                    "db8a9e233a010a61063f34220821ec76157a2d84"))
 (pet :source #1# :recipe
      (:package "pet" :fetcher github :repo "wyuenho/emacs-pet" :files
                ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir"
                 "doc/*.info" "doc/*.texi" "doc/*.texinfo" "lisp/*.el"
                 "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
                 (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el"
                           "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
                :source "MELPA" :protocol https :inherit t :depth treeless :ref
                "d9aa6a4dd2d7ce52febeafc31ac84d861ac1e222"))
 (json-navigator :source #1# :recipe
                 (:package "json-navigator" :fetcher github :repo
                           "DamienCassou/json-navigator" :files
                           ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                            "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                            "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                            "docs/*.texinfo"
                            (:exclude ".dir-locals.el" "test.el" "tests.el"
                                      "*-test.el" "*-tests.el" "LICENSE"
                                      "README*" "*-pkg.el"))
                           :source "MELPA" :protocol https :inherit t :depth
                           treeless :ref
                           "8ab49b066bc23de731a29ef07bbafa29999e1852"))
 (tree-mode :source #1# :recipe
            (:package "tree-mode" :fetcher github :repo
                      "emacsorphanage/tree-mode" :files
                      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                       "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                       "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                       "docs/*.texinfo"
                       (:exclude ".dir-locals.el" "test.el" "tests.el"
                                 "*-test.el" "*-tests.el" "LICENSE" "README*"
                                 "*-pkg.el"))
                      :source "MELPA" :protocol https :inherit t :depth treeless
                      :ref "b06078826d5875d74b0e7b7ac47b0d0917610534"))
 (php-mode :source #1# :recipe
           (:package "php-mode" :repo "emacs-php/php-mode" :fetcher github
                     :files
                     ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                      "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                      "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                      "docs/*.texinfo"
                      (:exclude ".dir-locals.el" "test.el" "tests.el"
                                "*-test.el" "*-tests.el" "LICENSE" "README*"
                                "*-pkg.el"))
                     :source "MELPA" :protocol https :inherit t :depth treeless
                     :ref "5b6cc1c068ba759dcf30067ad1e048b3693a40d7"))
 (json-mode :source #1# :recipe
            (:package "json-mode" :fetcher github :repo "json-emacs/json-mode"
                      :files
                      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                       "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                       "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                       "docs/*.texinfo"
                       (:exclude ".dir-locals.el" "test.el" "tests.el"
                                 "*-test.el" "*-tests.el" "LICENSE" "README*"
                                 "*-pkg.el"))
                      :source "MELPA" :protocol https :inherit t :depth treeless
                      :ref "466d5b563721bbeffac3f610aefaac15a39d90a9"))
 (magit :source #1# :recipe
        (:package "magit" :fetcher github :repo "magit/magit" :files
                  ("lisp/magit*.el" "lisp/git-*.el" "docs/magit.texi"
                   "docs/AUTHORS.md" "LICENSE" ".dir-locals.el"
                   (:exclude "lisp/magit-section.el"))
                  :source "MELPA" :protocol https :inherit t :depth treeless
                  :ref "f593e8dc8784d772b49284bf5cffaf52ceea6f81"))
 (transient :source #1# :recipe
            (:package "transient" :fetcher github :repo "magit/transient" :files
                      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                       "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                       "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                       "docs/*.texinfo"
                       (:exclude ".dir-locals.el" "test.el" "tests.el"
                                 "*-test.el" "*-tests.el" "LICENSE" "README*"
                                 "*-pkg.el"))
                      :source "MELPA" :protocol https :inherit t :depth treeless
                      :ref "52f737a696cad846d528a5a06e412f740a1de38a"))
 (edit-indirect :source #1# :recipe
                (:package "edit-indirect" :fetcher github :repo
                          "Fanael/edit-indirect" :files
                          ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                           "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                           "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                           "docs/*.texinfo"
                           (:exclude ".dir-locals.el" "test.el" "tests.el"
                                     "*-test.el" "*-tests.el" "LICENSE"
                                     "README*" "*-pkg.el"))
                          :source "MELPA" :protocol https :inherit t :depth
                          treeless :ref
                          "82a28d8a85277cfe453af464603ea330eae41c05"))
 (markdown-mode :source #1# :recipe
                (:package "markdown-mode" :fetcher github :repo
                          "jrblevin/markdown-mode" :files
                          ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                           "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                           "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                           "docs/*.texinfo"
                           (:exclude ".dir-locals.el" "test.el" "tests.el"
                                     "*-test.el" "*-tests.el" "LICENSE"
                                     "README*" "*-pkg.el"))
                          :source "MELPA" :protocol https :inherit t :depth
                          treeless :ref
                          "d2d960bec164e91e1a3315b176e2bcc324e63c95"))
 (xmind-org :source #1# :recipe
            (:package "xmind-org" :fetcher github :repo "akirak/xmind-org-el"
                      :files
                      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                       "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                       "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                       "docs/*.texinfo"
                       (:exclude ".dir-locals.el" "test.el" "tests.el"
                                 "*-test.el" "*-tests.el" "LICENSE" "README*"
                                 "*-pkg.el"))
                      :source "MELPA" :protocol https :inherit t :depth treeless
                      :ref "01055f0b9a53d40c9ce6a7b1c259a3a73b4ff413"))
 (sql-indent :source #1# :recipe
             (:package "sql-indent" :repo
                       ("https://github.com/alex-hhh/emacs-sql-indent"
                        . "sql-indent")
                       :files ("*" (:exclude ".git")) :source "GNU ELPA"
                       :protocol https :inherit t :depth treeless :ref
                       "2ed4c6a26b8f3d651ac6231eaafb2565d77c918b"))
 (mermaid-mode :source #1# :recipe
               (:package "mermaid-mode" :repo "abrochard/mermaid-mode" :fetcher
                         github :files
                         ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                          "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                          "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                          "docs/*.texinfo"
                          (:exclude ".dir-locals.el" "test.el" "tests.el"
                                    "*-test.el" "*-tests.el" "LICENSE" "README*"
                                    "*-pkg.el"))
                         :source "MELPA" :protocol https :inherit t :depth
                         treeless :ref
                         "e74d4da7612c7a88e07f9dd3369e3b9fd36f396c"))
 (chatgpt-shell :source #1# :recipe
                (:package "chatgpt-shell" :fetcher github :repo
                          "xenodium/chatgpt-shell" :files
                          ("*.el"
                           (:exclude "test_chatgpt-shell.el" "shell-maker.el"
                                     "ob-chatgpt-shell.el" "dall-e-shell.el"
                                     "ob-dall-e-shell.el"))
                          :source "MELPA" :protocol https :inherit t :depth
                          treeless :ref
                          "fcc18a1534dfdb91e2a11e09b45ae14dc9dd50f3"))
 (auth-source-1password :source #1# :recipe
                        (:package "auth-source-1password" :fetcher github :repo
                                  "dlobraico/auth-source-1password" :files
                                  ("*.el" "*.el.in" "dir" "*.info" "*.texi"
                                   "*.texinfo" "doc/dir" "doc/*.info"
                                   "doc/*.texi" "doc/*.texinfo" "lisp/*.el"
                                   "docs/dir" "docs/*.info" "docs/*.texi"
                                   "docs/*.texinfo"
                                   (:exclude ".dir-locals.el" "test.el"
                                             "tests.el" "*-test.el" "*-tests.el"
                                             "LICENSE" "README*" "*-pkg.el"))
                                  :source "MELPA" :protocol https :inherit t
                                  :depth treeless :ref
                                  "7bb8ad3507c58cc642b2ebbd7e57a91efab80e14"))
 (copilot :source #1# :recipe
          (:package "copilot" :fetcher github :repo "copilot-emacs/copilot.el"
                    :files
                    ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                     "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                     "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                     "docs/*.texinfo"
                     (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el"
                               "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
                    :source "MELPA" :protocol https :inherit t :depth treeless
                    :ref "7d105d708a23d16cdfd5240500be8bb02f95a46e"))
 (gptel :source #1# :recipe
        (:package "gptel" :repo "karthink/gptel" :fetcher github :files
                  ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                   "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                   "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                   "docs/*.texinfo"
                   (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el"
                             "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
                  :source "MELPA" :protocol https :inherit t :depth treeless
                  :ref "4be3d8da7c924daaf34fbde91e0dd77340740f5a"))
 (eldoc :source #1# :recipe
        (:package "eldoc" :repo
                  ("https://github.com/emacs-mirror/emacs" . "eldoc") :branch
                  "master" :files ("lisp/emacs-lisp/eldoc.el" (:exclude ".git"))
                  :source "GNU ELPA" :protocol https :inherit t :depth treeless
                  :ref "0e1f81b9bc469c7b115d1abcd12c20aae4160dd7"))
 (jinx :source #1# :recipe
       (:package "jinx" :repo "minad/jinx" :files
                 (:defaults "jinx-mod.c" "emacs-module.h") :fetcher github
                 :source "MELPA" :protocol https :inherit t :depth treeless :ref
                 "9c778357ffaac972c86f4acd39d70c547abcaf46"))
 (beframe :source #1# :recipe
          (:package "beframe" :repo
                    ("https://github.com/protesilaos/beframe" . "beframe")
                    :files ("*" (:exclude ".git" "COPYING" "doclicense.texi"))
                    :source "GNU ELPA" :protocol https :inherit t :depth
                    treeless :ref "94b5122122959ea38cf257916edaf29e4ab02949"))
 (treemacs-magit :source #1# :recipe
                 (:package "treemacs-magit" :fetcher github :repo
                           "Alexander-Miller/treemacs" :files
                           ("src/extra/treemacs-magit.el") :source "MELPA"
                           :protocol https :inherit t :depth treeless :ref
                           "32bb3dd02ddfca85661614b3b227e770fab821e2"))
 (treemacs-icons-dired :source #1# :recipe
                       (:package "treemacs-icons-dired" :fetcher github :repo
                                 "Alexander-Miller/treemacs" :files
                                 ("src/extra/treemacs-icons-dired.el") :source
                                 "MELPA" :protocol https :inherit t :depth
                                 treeless :ref
                                 "32bb3dd02ddfca85661614b3b227e770fab821e2"))
 (treemacs-evil :source #1# :recipe
                (:package "treemacs-evil" :fetcher github :repo
                          "Alexander-Miller/treemacs" :files
                          ("src/extra/treemacs-evil.el") :source "MELPA"
                          :protocol https :inherit t :depth treeless :ref
                          "32bb3dd02ddfca85661614b3b227e770fab821e2"))
 (treemacs :source #1# :recipe
           (:package "treemacs" :fetcher github :repo
                     "Alexander-Miller/treemacs" :files
                     (:defaults "Changelog.org" "icons" "src/elisp/treemacs*.el"
                                "src/scripts/treemacs*.py"
                                (:exclude "src/extra/*"))
                     :source "MELPA" :protocol https :inherit t :depth treeless
                     :ref "32bb3dd02ddfca85661614b3b227e770fab821e2"))
 (org-gtd :source #1# :recipe
          (:package "org-gtd" :fetcher github :repo "Trevoke/org-gtd.el" :files
                    ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                     "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                     "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                     "docs/*.texinfo"
                     (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el"
                               "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
                    :source "MELPA" :protocol https :inherit t :depth treeless
                    :ref "f82eb971db0008b773a57c207120751f913bde6b"))
 (org-contrib :source #1# :recipe
              (:package "org-contrib" :repo
                        ("https://git.sr.ht/~bzg/org-contrib" . "org-contrib")
                        :files (:defaults) :source "Org" :protocol https
                        :inherit t :depth treeless :ref
                        "f1f6b6ec812803ff99693255555a82960fb3545a"))
 (eat :source #1# :recipe
      (:package "eat" :repo ("https://codeberg.org/akib/emacs-eat" . "eat")
                :files ("*" (:exclude ".git")) :source "NonGNU ELPA" :protocol
                https :inherit t :depth treeless :ref
                "c8d54d649872bfe7b2b9f49ae5c2addbf12d3b99"))
 (f :source #1# :recipe
    (:package "f" :fetcher github :repo "rejeep/f.el" :files
              ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir"
               "doc/*.info" "doc/*.texi" "doc/*.texinfo" "lisp/*.el" "docs/dir"
               "docs/*.info" "docs/*.texi" "docs/*.texinfo"
               (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el"
                         "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
              :source "MELPA" :protocol https :inherit t :depth treeless :ref
              "931b6d0667fe03e7bf1c6c282d6d8d7006143c52"))
 (dash :source #1# :recipe
       (:package "dash" :fetcher github :repo "magnars/dash.el" :files
                 ("dash.el" "dash.texi") :source "MELPA" :protocol https
                 :inherit t :depth treeless :ref
                 "fcb5d831fc08a43f984242c7509870f30983c27c"))
 (s :source #1# :recipe
    (:package "s" :fetcher github :repo "magnars/s.el" :files
              ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir"
               "doc/*.info" "doc/*.texi" "doc/*.texinfo" "lisp/*.el" "docs/dir"
               "docs/*.info" "docs/*.texi" "docs/*.texinfo"
               (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el"
                         "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
              :source "MELPA" :protocol https :inherit t :depth treeless :ref
              "dda84d38fffdaf0c9b12837b504b402af910d01d"))
 (shrink-path :source #1# :recipe
              (:package "shrink-path" :fetcher gitlab :repo
                        "bennya/shrink-path.el" :files
                        ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                         "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                         "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                         "docs/*.texinfo"
                         (:exclude ".dir-locals.el" "test.el" "tests.el"
                                   "*-test.el" "*-tests.el" "LICENSE" "README*"
                                   "*-pkg.el"))
                        :source "MELPA" :protocol https :inherit t :depth
                        treeless :ref "c14882c8599aec79a6e8ef2d06454254bb3e1e41"))
 (annalist :source #1# :recipe
           (:package "annalist" :fetcher github :repo "noctuid/annalist.el"
                     :files
                     ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                      "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                      "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                      "docs/*.texinfo"
                      (:exclude ".dir-locals.el" "test.el" "tests.el"
                                "*-test.el" "*-tests.el" "LICENSE" "README*"
                                "*-pkg.el"))
                     :source "MELPA" :protocol https :inherit t :depth treeless
                     :ref "e1ef5dad75fa502d761f70d9ddf1aeb1c423f41d"))
 (goto-chg :source #1# :recipe
           (:package "goto-chg" :repo "emacs-evil/goto-chg" :fetcher github
                     :files
                     ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                      "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                      "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                      "docs/*.texinfo"
                      (:exclude ".dir-locals.el" "test.el" "tests.el"
                                "*-test.el" "*-tests.el" "LICENSE" "README*"
                                "*-pkg.el"))
                     :source "MELPA" :protocol https :inherit t :depth treeless
                     :ref "72f556524b88e9d30dc7fc5b0dc32078c166fda7"))
 (avy :source #1# :recipe
      (:package "avy" :repo "abo-abo/avy" :fetcher github :files
                ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir"
                 "doc/*.info" "doc/*.texi" "doc/*.texinfo" "lisp/*.el"
                 "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
                 (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el"
                           "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
                :source "MELPA" :protocol https :inherit t :depth treeless :ref
                "933d1f36cca0f71e4acb5fac707e9ae26c536264"))
 (dirvish :source #1# :recipe
          (:package "dirvish" :fetcher github :repo "alexluigit/dirvish" :files
                    (:defaults "extensions/*.el") :source "MELPA" :protocol
                    https :inherit t :depth treeless :ref
                    "a854e2b90176a158c774ff03a5772af7749b63bc"))
 (doom-modeline :source #1# :recipe
                (:package "doom-modeline" :repo "seagle0128/doom-modeline"
                          :fetcher github :files
                          ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                           "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                           "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                           "docs/*.texinfo"
                           (:exclude ".dir-locals.el" "test.el" "tests.el"
                                     "*-test.el" "*-tests.el" "LICENSE"
                                     "README*" "*-pkg.el"))
                          :source "MELPA" :protocol https :inherit t :depth
                          treeless :ref
                          "ec27cdb3cf1fec1db63c752b3654c9de28e22089"))
 (nerd-icons :source #1# :recipe
             (:package "nerd-icons" :repo "rainstormstudio/nerd-icons.el"
                       :fetcher github :files (:defaults "data") :source "MELPA"
                       :protocol https :inherit t :depth treeless :ref
                       "6612cc65373b63e85362b6a5d0bbd440b05be58b"))
 (all-the-icons :source #1# :recipe
                (:package "all-the-icons" :repo "domtronn/all-the-icons.el"
                          :fetcher github :files (:defaults "data") :source
                          "MELPA" :protocol https :inherit t :depth treeless
                          :ref "39ef44f810c34e8900978788467cc675870bcd19"))
 (diminish :source #1# :recipe
           (:package "diminish" :fetcher github :repo "myrjola/diminish.el"
                     :files
                     ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                      "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                      "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                      "docs/*.texinfo"
                      (:exclude ".dir-locals.el" "test.el" "tests.el"
                                "*-test.el" "*-tests.el" "LICENSE" "README*"
                                "*-pkg.el"))
                     :source "MELPA" :protocol https :inherit t :depth treeless
                     :ref "fbd5d846611bad828e336b25d2e131d1bc06b83d"))
 (evil-snipe :source #1# :recipe
             (:package "evil-snipe" :repo "hlissner/evil-snipe" :fetcher github
                       :files
                       ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                        "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                        "docs/*.texinfo"
                        (:exclude ".dir-locals.el" "test.el" "tests.el"
                                  "*-test.el" "*-tests.el" "LICENSE" "README*"
                                  "*-pkg.el"))
                       :source "MELPA" :protocol https :inherit t :depth
                       treeless :ref "c2108d3932fcd2f75ac3e48250d6badd668f5b4f"))
 (evil-surround :source #1# :recipe
                (:package "evil-surround" :repo "emacs-evil/evil-surround"
                          :fetcher github :old-names (surround) :files
                          ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                           "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                           "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                           "docs/*.texinfo"
                           (:exclude ".dir-locals.el" "test.el" "tests.el"
                                     "*-test.el" "*-tests.el" "LICENSE"
                                     "README*" "*-pkg.el"))
                          :source "MELPA" :protocol https :inherit t :depth
                          treeless :ref
                          "da05c60b0621cf33161bb4335153f75ff5c29d91"))
 (evil-visualstar :source #1# :recipe
                  (:package "evil-visualstar" :repo "bling/evil-visualstar"
                            :fetcher github :files
                            ("*.el" "*.el.in" "dir" "*.info" "*.texi"
                             "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi"
                             "doc/*.texinfo" "lisp/*.el" "docs/dir"
                             "docs/*.info" "docs/*.texi" "docs/*.texinfo"
                             (:exclude ".dir-locals.el" "test.el" "tests.el"
                                       "*-test.el" "*-tests.el" "LICENSE"
                                       "README*" "*-pkg.el"))
                            :source "MELPA" :protocol https :inherit t :depth
                            treeless :ref
                            "06c053d8f7381f91c53311b1234872ca96ced752"))
 (undo-fu-session :source #1# :recipe
                  (:package "undo-fu-session" :fetcher codeberg :repo
                            "ideasman42/emacs-undo-fu-session" :files
                            ("*.el" "*.el.in" "dir" "*.info" "*.texi"
                             "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi"
                             "doc/*.texinfo" "lisp/*.el" "docs/dir"
                             "docs/*.info" "docs/*.texi" "docs/*.texinfo"
                             (:exclude ".dir-locals.el" "test.el" "tests.el"
                                       "*-test.el" "*-tests.el" "LICENSE"
                                       "README*" "*-pkg.el"))
                            :source "MELPA" :protocol https :inherit t :depth
                            treeless :ref
                            "d90d42ddba8fa42ef5dc109196545caeabb42b75"))
 (undo-fu :source #1# :recipe
          (:package "undo-fu" :fetcher codeberg :repo "ideasman42/emacs-undo-fu"
                    :files
                    ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                     "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                     "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                     "docs/*.texinfo"
                     (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el"
                               "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
                    :source "MELPA" :protocol https :inherit t :depth treeless
                    :ref "399cc12f907f81a709f9014b6fad0205700d5772"))
 (evil-org :source #1# :recipe
           (:package "evil-org" :fetcher github :repo "Somelauw/evil-org-mode"
                     :files
                     ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                      "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                      "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                      "docs/*.texinfo"
                      (:exclude ".dir-locals.el" "test.el" "tests.el"
                                "*-test.el" "*-tests.el" "LICENSE" "README*"
                                "*-pkg.el"))
                     :source "MELPA" :protocol https :inherit t :depth treeless
                     :ref "b1f309726b1326e1a103742524ec331789f2bf94"))
 (evil-collection :source #1# :recipe
                  (:package "evil-collection" :fetcher github :repo
                            "emacs-evil/evil-collection" :files
                            (:defaults "modes") :source "MELPA" :protocol https
                            :inherit t :depth treeless :ref
                            "cb850ff0d11f644dbd133428cff57e82e655ecd7"))
 (evil :source #1# :recipe
       (:package "evil" :repo "emacs-evil/evil" :fetcher github :files
                 (:defaults "doc/build/texinfo/evil.texi"
                            (:exclude "evil-test-helpers.el"))
                 :source "MELPA" :protocol https :inherit t :depth treeless :ref
                 "94f9517f66be80395ef7ba3604278ed5624b9529"))
 (cape :source #1# :recipe
       (:package "cape" :repo "minad/cape" :fetcher github :files
                 ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo" "doc/dir"
                  "doc/*.info" "doc/*.texi" "doc/*.texinfo" "lisp/*.el"
                  "docs/dir" "docs/*.info" "docs/*.texi" "docs/*.texinfo"
                  (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el"
                            "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
                 :source "MELPA" :protocol https :inherit t :depth treeless :ref
                 "f72ebcaeff4252ca0d7a9ac4636d8db0fdf54c55"))
 (corfu :source #1# :recipe
        (:package "corfu" :repo "minad/corfu" :files
                  (:defaults "extensions/corfu-*.el") :fetcher github :source
                  "MELPA" :protocol https :inherit t :depth treeless :ref
                  "c302b0526ad9d0c99d1d0639df63f6ca65accfc3"))
 (outline-indent :source #1# :recipe
                 (:package "outline-indent" :fetcher github :repo
                           "jamescherti/outline-indent.el" :files
                           ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                            "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                            "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                            "docs/*.texinfo"
                            (:exclude ".dir-locals.el" "test.el" "tests.el"
                                      "*-test.el" "*-tests.el" "LICENSE"
                                      "README*" "*-pkg.el"))
                           :source "MELPA" :protocol https :inherit t :depth
                           treeless :ref
                           "ff1b6ecf642c673936f3c258d329c76c45e30854"))
 (consult :source #1# :recipe
          (:package "consult" :repo "minad/consult" :fetcher github :files
                    ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                     "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                     "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                     "docs/*.texinfo"
                     (:exclude ".dir-locals.el" "test.el" "tests.el" "*-test.el"
                               "*-tests.el" "LICENSE" "README*" "*-pkg.el"))
                    :source "MELPA" :protocol https :inherit t :depth treeless
                    :ref "fa223d826fa3e6e6cce91dbf5432cab84ef83b66"))
 (embark-consult :source #1# :recipe
                 (:package "embark-consult" :repo "oantolin/embark" :fetcher
                           github :files ("embark-consult.el") :source "MELPA"
                           :protocol https :inherit t :depth treeless :ref
                           "d5df0eff182b014ab49328a4dbb1d69eb7faafbd"))
 (embark :source #1# :recipe
         (:package "embark" :repo "oantolin/embark" :fetcher github :files
                   ("embark.el" "embark-org.el" "embark.texi") :source "MELPA"
                   :protocol https :inherit t :depth treeless :ref
                   "d5df0eff182b014ab49328a4dbb1d69eb7faafbd"))
 (marginalia :source #1# :recipe
             (:package "marginalia" :repo "minad/marginalia" :fetcher github
                       :files
                       ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                        "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                        "docs/*.texinfo"
                        (:exclude ".dir-locals.el" "test.el" "tests.el"
                                  "*-test.el" "*-tests.el" "LICENSE" "README*"
                                  "*-pkg.el"))
                       :source "MELPA" :protocol https :inherit t :depth
                       treeless :ref "c51fd9e4d4258543e0cd8dedda941789163bec5a"))
 (orderless :source #1# :recipe
            (:package "orderless" :repo "oantolin/orderless" :fetcher github
                      :files
                      ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                       "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                       "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                       "docs/*.texinfo"
                       (:exclude ".dir-locals.el" "test.el" "tests.el"
                                 "*-test.el" "*-tests.el" "LICENSE" "README*"
                                 "*-pkg.el"))
                      :source "MELPA" :protocol https :inherit t :depth treeless
                      :ref "254f2412489bbbf62700f9d3d5f18e537841dcc3"))
 (vertico :source #1# :recipe
          (:package "vertico" :repo "minad/vertico" :files
                    (:defaults "extensions/vertico-*.el") :fetcher github
                    :source "MELPA" :protocol https :inherit t :depth treeless
                    :ref "026a81a9c893b1d73cdbcb12436a0fad3ebdeb5f"))
 (ace-window :source #1# :recipe
             (:package "ace-window" :repo "abo-abo/ace-window" :fetcher github
                       :files
                       ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                        "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                        "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                        "docs/*.texinfo"
                        (:exclude ".dir-locals.el" "test.el" "tests.el"
                                  "*-test.el" "*-tests.el" "LICENSE" "README*"
                                  "*-pkg.el"))
                       :source "MELPA" :protocol https :inherit t :depth
                       treeless :ref "77115afc1b0b9f633084cf7479c767988106c196"))
 (spacious-padding :source #1# :recipe
                   (:package "spacious-padding" :repo
                             ("https://github.com/protesilaos/spacious-padding"
                              . "spacious-padding")
                             :files
                             ("*" (:exclude ".git" "COPYING" "doclicense.texi"))
                             :source "GNU ELPA" :protocol https :inherit t
                             :depth treeless :ref
                             "2bfcb8da5f7f08e39c52c889231f2b6f93f10e78"))
 (olivetti :source #1# :recipe
           (:package "olivetti" :fetcher github :repo "rnkn/olivetti" :files
                     ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                      "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                      "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                      "docs/*.texinfo"
                      (:exclude ".dir-locals.el" "test.el" "tests.el"
                                "*-test.el" "*-tests.el" "LICENSE" "README*"
                                "*-pkg.el"))
                     :source "MELPA" :protocol https :inherit t :depth treeless
                     :ref "845eb7a95a3ca3325f1120c654d761b91683f598"))
 (ef-themes :source #1# :recipe
            (:package "ef-themes" :repo
                      ("https://github.com/protesilaos/ef-themes" . "ef-themes")
                      :files
                      ("*"
                       (:exclude ".git" "COPYING" "doclicense.texi"
                                 "contrast-ratios.org"))
                      :source "GNU ELPA" :protocol https :inherit t :depth
                      treeless :ref "3dd2f8fb425abdcbeb5e4b648fc48dbd508648eb"))
 (fontaine :source #1# :recipe
           (:package "fontaine" :repo
                     ("https://github.com/protesilaos/fontaine" . "fontaine")
                     :files ("*" (:exclude ".git" "COPYING" "doclicense.texi"))
                     :source "GNU ELPA" :protocol https :inherit t :depth
                     treeless :ref "fe78a2be64b09f55748fa0c6e62d59e787b761b4"))
 (compile-angel :source #1# :recipe
                (:package "compile-angel" :fetcher github :repo
                          "jamescherti/compile-angel.el" :files
                          ("*.el" "*.el.in" "dir" "*.info" "*.texi" "*.texinfo"
                           "doc/dir" "doc/*.info" "doc/*.texi" "doc/*.texinfo"
                           "lisp/*.el" "docs/dir" "docs/*.info" "docs/*.texi"
                           "docs/*.texinfo"
                           (:exclude ".dir-locals.el" "test.el" "tests.el"
                                     "*-test.el" "*-tests.el" "LICENSE"
                                     "README*" "*-pkg.el"))
                          :source "MELPA" :protocol https :inherit t :depth
                          treeless :ref
                          "ea7c270a6f56df9c29b76e586135f7d6e29c5fb0"))
 (exec-path-from-shell :source #1# :recipe
                       (:package "exec-path-from-shell" :fetcher github :repo
                                 "purcell/exec-path-from-shell" :files
                                 ("*.el" "*.el.in" "dir" "*.info" "*.texi"
                                  "*.texinfo" "doc/dir" "doc/*.info"
                                  "doc/*.texi" "doc/*.texinfo" "lisp/*.el"
                                  "docs/dir" "docs/*.info" "docs/*.texi"
                                  "docs/*.texinfo"
                                  (:exclude ".dir-locals.el" "test.el"
                                            "tests.el" "*-test.el" "*-tests.el"
                                            "LICENSE" "README*" "*-pkg.el"))
                                 :source "MELPA" :protocol https :inherit t
                                 :depth treeless :ref
                                 "4896a797252fbfdac32fb77508500ac7d220f717"))
 (elpaca-use-package :source #1# :recipe
                     (:package "elpaca-use-package" :wait t :repo
                               "https://github.com/progfolio/elpaca.git" :files
                               ("extensions/elpaca-use-package.el") :main
                               "extensions/elpaca-use-package.el" :build
                               (:not elpaca--compile-info) :source
                               "Elpaca extensions" :protocol https :inherit t
                               :depth treeless :ref
                               "2f6a19b9723c12bfc5e2fdb2a495d93933829213"))
 (elpaca :source
   #1# :recipe
   (:source nil :protocol https :inherit ignore :depth 1 :repo
            "https://github.com/progfolio/elpaca.git" :ref
            "2f6a19b9723c12bfc5e2fdb2a495d93933829213" :files
            (:defaults "elpaca-test.el" (:exclude "extensions")) :build
            (:not elpaca--activate-package) :package "elpaca")))
