# Compiler and flags from LLVM
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S), Darwin)
	LLVM_CONFIG := $(shell brew --prefix llvm@18)/bin/llvm-config
    CXXFLAGS := -mmacosx-version-min=12.7
	LDFLAGS := 
else
	LLVM_CONFIG := llvm-config-18
	CXXFLAGS := 
	LDFLAGS := 
endif

CXXFLAGS += $(shell $(LLVM_CONFIG) --cxxflags)
LDFLAGS += $(shell $(LLVM_CONFIG) --ldflags --system-libs --libs core orcjit native)

CXX := $(shell $(LLVM_CONFIG) --bindir)/clang++

# Directories
SRCDIR := src
BUILDDIR := build

# Source files and object files
SRCS := $(wildcard $(SRCDIR)/*.cpp)
OBJS := $(patsubst $(SRCDIR)/%.cpp,$(BUILDDIR)/%.o,$(SRCS))
EXEC := bin/toy

# Default target
all: $(EXEC)

# Ensure the build directory exists
$(BUILDDIR):
	mkdir -p bin
	mkdir -p $(BUILDDIR)

# Rule to link the executable
$(EXEC): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $(OBJS) $(LDFLAGS)

# Rule to compile .cpp files into .o files in the build directory
$(BUILDDIR)/%.o: $(SRCDIR)/%.cpp | $(BUILDDIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean up
clean:
	rm -rf $(BUILDDIR) $(EXEC)

.PHONY: all clean
