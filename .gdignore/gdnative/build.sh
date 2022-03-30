cargo build --release
rm ../../lib/gdnative_linux.so
cp target/release/libgdnative.so ../../lib/gdnative_linux.so
