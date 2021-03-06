#!/bin/bash
# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Note: This script runs on Mac and Linux. It requires `mono` to be installed
# and `flatc` to be built (using `cmake` in the root directory).

sampledir=$(cd $(dirname $BASH_SOURCE) && pwd)
rootidr=$(cd $sampledir/.. && pwd)
currentdir=$(pwd)

if [[ "$sampledir" != "$currentdir" ]]; then
  echo Error: This script must be run from inside the $sampledir directory.
  echo You executed it from the $currentdir directory.
  exit 1
fi

# Run `flatc`. Note: This requires you to compile using `cmake` from the
# root `/flatbuffers` directory.
if [ -e ../flatc ]; then
  ../flatc --dlang --gen-mutable monster.fbs
elif [ -e ../Debug/flatc ]; then
  ../Debug/flatc --dlang --gen-mutable monster.fbs 
else
  echo 'flatc' could not be found. Make sure to build FlatBuffers from the \
       $rootdir directory.
  exit 1
fi

echo Compiling and running the D sample.

# Compile and execute the sample.
dmd -lib -of./libflatbuffers.a \
-I../dlang/source/ \
../dlang/source/flatbuffers/bytebuffer.d \
../dlang/source/flatbuffers/exception.d \
../dlang/source/flatbuffers/flatbufferbuilder.d \
../dlang/source/flatbuffers/package.d \
../dlang/source/flatbuffers/table.d \
-vcolumns

dmd -c -of./sample_binary.o \
-I./ -I../dlang/source/  \
MyGame/Sample/Color.d \
MyGame/Sample/Equipment.d \
MyGame/Sample/Monster.d \
MyGame/Sample/package.d \
MyGame/Sample/Vec3.d \
MyGame/Sample/Weapon.d \
sample_binary.d -vcolumns

dmd -of./sample_binary ./sample_binary.o ./libflatbuffers.a -L--no-as-needed

./sample_binary
#mcs SampleBinary.cs MyGame/Sample/*.cs ../net/FlatBuffers/*.cs
#mono SampleBinary.exe

# Cleanup temporary files.
rm libflatbuffers.a
rm sample_binary
rm sample_binary.o
rm -rf mygame
