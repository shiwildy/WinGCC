# WinGCC
WinGCC is a cross-compiled version of the (GCC) for 64-bit Windows. It allows developers to use GCC in Windows environment.

## Installation
To install WinGCC, please download the latest release from the [GitHub Releases page](https://github.com/your-repo/wingcc/releases).

1. Visit the [Releases page](https://github.com/shiwildy/WinGCC/releases).
2. Download the appropriate installer for your system.
3. Follow the installation instructions in the setup file.

## Testing

Once installed, you can use WinGCC to compile programs:

#### Create a file named `main.cpp`
```cpp
#include <iostream>

int main() {
    std::cout << "Hello world";
    return 0;
}
```

#### Compile the file using g++
```bash
g++ main.cpp -o main.exe
```

#### Run the compiled program
```text
main.exe
```

#### Expected Output
```text
Hello world
```

## Contribution
We welcome contributions! Feel free to open issues or submit pull requests to improve WinGCC.
