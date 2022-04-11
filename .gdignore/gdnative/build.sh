cargo build --release
rm ../../lib/gdnative_linux.so
cp target/release/libgdnative.so ../../bin/linux-64/generator.so
