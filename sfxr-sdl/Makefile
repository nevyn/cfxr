CXXFLAGS=-ggdb -O2 `sdl-config --cflags` `pkg-config gtk+-2.0 --cflags`
LDFLAGS=`sdl-config --libs` `pkg-config gtk+-2.0 --libs`

sfxr: main.cpp tools.h sdlkit.h
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $< -o $@
