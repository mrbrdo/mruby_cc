#!/bin/sh

cd mruby
make
cd ..

cd mrbcc_mrblib
ruby compile_mrblib.rb
mv mrblib.so ../
cd ..

cd standalone_runner
make
mv mrbcc_runner ../runner
cd ..

echo "Done."
