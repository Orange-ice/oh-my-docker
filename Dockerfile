FROM archlinux:base-devel

WORKDIR /tmp
ENV SHELL /bin/bash
ADD mirrorlist /etc/pacman.d/mirrorlist
RUN yes | pacman -Syu 
RUN yes | pacman -S git zsh
VOLUME [ "/root/", "/root/.local/share/chezmoi", "/root/repos", "/root/.vscode-server/extensions", "/root/go/bin", "/var/lib/docker" ]
# end 

# bash
ADD bashrc /root/.bashrc
ADD z /root/.config/z 
# end

# zsh
RUN zsh -c 'git clone https://code.aliyun.com/412244196/prezto.git "$HOME/.zprezto"' &&\
	zsh -c 'setopt EXTENDED_GLOB' &&\
	zsh -c 'for rcfile in "$HOME"/.zprezto/runcoms/z*; do ln -s "$rcfile" "$HOME/.${rcfile:t}"; done'
ENV SHELL /bin/zsh
RUN echo 'source /root/.bashrc' >> /root/.zshrc
# end

# basic tools
RUN yes | pacman -S curl tree
ENV EDITOR=vim
ENV VISUAL=vim
# end

# Ruby
ADD rvm-stable.tar.gz /tmp/rvm-stable.tar.gz
ENV PATH="/usr/local/rvm/bin:$PATH"
RUN mv /tmp/rvm-stable.tar.gz/rvm-rvm-6bfc921 /tmp/rvm && cd /tmp/rvm && ./install --auto-dotfiles &&\
		echo "ruby_url=https://cache.ruby-china.com/pub/ruby" > /usr/local/rvm/user/db &&\
		echo 'gem: --no-document --verbose' > "$HOME/.gemrc" &&\
		rvm install ruby-3
# end 

# Install Go
RUN yes | pacman -S go
ENV GOPATH /root/go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH" 
ENV GOROOT /usr/lib/go
RUN go env -w GO111MODULE=on &&\
    go env -w GOPROXY=https://goproxy.cn,direct &&\
		go install github.com/silenceper/gowatch@latest
# end

# Dev env for JS
ENV PNPM_HOME /root/.local/share/pnpm
ENV PATH $PNPM_HOME:$PATH
RUN yes | pacman -Syu && yes | pacman -S nodejs npm &&\
    npm config set registry=https://registry.npmmirror.com &&\
		corepack enable &&\
		pnpm setup &&\
		pnpm i -g http-server
# end

# tools
RUN yes | pacman -S fzf openssh exa the_silver_searcher fd rsync &&\
		ssh-keygen -t rsa -N '' -f /etc/ssh/ssh_host_rsa_key &&\
		ssh-keygen -t dsa -N '' -f /etc/ssh/ssh_host_dsa_key
# end


# fq
RUN yes | pacman -S trojan proxychains-ng
# end

# dev deps
RUN yes | pacman -S postgresql-libs

# nvm
ENV NVM_DIR /root/.nvm
ADD nvm-0.39.1 /root/.nvm/
RUN sh ${NVM_DIR}/nvm.sh &&\
	echo '' >> /root/.zshrc &&\
	echo 'export NVM_DIR="$HOME/.nvm"' >> /root/.zshrc &&\
	echo '[ -s "${NVM_DIR}/nvm.sh" ] && { source "${NVM_DIR}/nvm.sh" }' >> /root/.zshrc &&\
	echo '[ -s "${NVM_DIR}/bash_completion" ] && { source "${NVM_DIR}/bash_completion" } ' >> /root/.zshrc
# end 

############### disabled
# # docker in docker 
# RUN yes | pacman -S docker &&\
# 		mkdir -p /etc/docker &&\
# 		echo '{"registry-mirrors": ["http://f1361db2.m.daocloud.io"]}' > /etc/docker/daemon.json 

# Rust
# WORKDIR /tmp
# ADD .cargo.cn.config /root/.cargo/config
# ENV RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
# ENV RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
# ENV CARGO_HTTP_MULTIPLEXING=false
# ENV PATH="/root/.cargo/bin:${PATH}"
# RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
# end

# Java
# RUN yes | pacman -S jre-openjdk-headless jdk-openjdk
# ENV JAVA_HOME=/usr/lib/jvm/default/
# ENV PATH=$JAVA_HOME/bin:$PATH
# end

# neovim
# RUN git clone --depth=1 https://github.com/frankfang/nvim-config.git /root/.config/nvim/ &&\
# 		git clone --depth=1 https://github.com/wbthomason/packer.nvim /root/.local/share/nvim/site/pack/packer/opt/packer.nvim &&\     
# 		git clone --depth=1 https://github.com/navarasu/onedark.nvim.git /root/.local/share/nvim/site/pack/packer/opt/onedark.nvim &&\ 
# 		git clone --depth=1 https://hub.fastgit.org/lifepillar/vim-gruvbox8 /root/.local/share/nvim/site/pack/packer/opt/vim-gruvbox8 &&\
# 		git clone --depth=1 https://hub.fastgit.org/sainnhe/edge /root/.local/share/nvim/site/pack/packer/opt/edge &&\
# 		git clone --depth=1 https://hub.fastgit.org/sainnhe/sonokai /root/.local/share/nvim/site/pack/packer/opt/sonokai &&\
# 		git clone --depth=1 https://hub.fastgit.org/sainnhe/gruvbox-material /root/.local/share/nvim/site/pack/packer/opt/gruvbox-material &&\
# 		git clone --depth=1 https://hub.fastgit.org/shaunsingh/nord.nvim /root/.local/share/nvim/site/pack/packer/opt/nord.nvim &&\    
# 		git clone --depth=1 https://hub.fastgit.org/NTBBloodbath/doom-one.nvim /root/.local/share/nvim/site/pack/packer/opt/doom-one.nvim &&\
# 		git clone --depth=1 https://hub.fastgit.org/sainnhe/everforest /root/.local/share/nvim/site/pack/packer/opt/everforest &&\     
# 		git clone --depth=1 https://hub.fastgit.org/EdenEast/nightfox.nvim /root/.local/share/nvim/site/pack/packer/opt/nightfox.nvim &&\
# 		pip install -U pynvim &&\
# 		pip install 'python-lsp-server[all]' pylsp-mypy pyls-isort vim-vint &&\
# 	  yarn global add vim-language-server && \
# 		yes | pacman -S ripgrep
# RUN nvim +PackerSync +30sleep +qall
# # end 

# # Python 3 and pip
# ENV PYTHONUNBUFFERED=1
# ENV PATH="/root/.local/bin:$PATH"
# ADD pip.cn.conf /root/.config/pip/pip.conf
# RUN python -m ensurepip &&\
# 	python -m pip install --no-cache --upgrade pip setuptools wheel
# # end