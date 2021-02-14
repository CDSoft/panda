#!/bin/bash

# This file is part of Panda.
#
# Panda is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Panda is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Panda.  If not, see <https://www.gnu.org/licenses/>.
#
# For further information about Panda you can visit
# http://cdelord.fr/panda

$GRC make $*
while true
do
    printf "\\e[44m### %-$(($(tput cols) - 4))s\\e[0m\\r" "waiting for changes..."
    if inotifywait -q -r --exclude "\.git|\.sw." -e modify . > /dev/null
    then
        printf "\\e[44m### %-$(($(tput cols) - 4))s\\e[0m\\n" "make"
        sleep 1
        $GRC make $*
    fi
done
