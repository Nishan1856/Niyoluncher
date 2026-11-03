SHELL := /bin/bash
.SHELLFLAGS = -ec

# Prerequisite variables
SOURCEDIR := src
OUTPUTDIR := build

SOURCES := $(shell find $(SOURCEDIR) -type f -name '*.java')
CLASSES := $(SOURCES:$(SOURCEDIR)/%.java=$(OUTPUTDIR)/%.class)

TARGETS := $(shell find $(SOURCEDIR) -mindepth 1 -maxdepth 1 -type d)
TARGETS := $(filter-out $(OUTPUTDIR)/lwjgl.jar,$(TARGETS:$(SOURCEDIR)/%=$(OUTPUTDIR)/%.jar))

# Bundled LWJGL versions come from the same list JavaLauncher reads at runtime,
# oldest first. Each one needs JavaApp/libs/lwjgl-<version>.
LWJGL_MANIFEST := ../Natives/resources/lwjgl_versions.txt
LWJGL_VERSIONS := $(shell awk '/^[ \t]*\#/ {next} NF {print $$1}' $(LWJGL_MANIFEST))
LWJGL_SDL_VERSIONS := $(shell awk '/^[ \t]*\#/ {next} {for (i = 3; i <= NF; i++) if ($$i == "sdl") print $$1}' $(LWJGL_MANIFEST))
ifeq ($(LWJGL_VERSIONS),)
$(error No LWJGL versions found in $(LWJGL_MANIFEST))
endif
LWJGL_JARS := $(LWJGL_VERSIONS:%=$(OUTPUTDIR)/lwjgl-%.jar)

# Add all jars to classpath and allow compiling with private API.
# This remains the normal classpath for the existing launcher and
# LWJGL 3.3.3 sources.
JCFLAGS := -cp "$(subst $() $(),:,$(wildcard $(SOURCEDIR)/*/):$(wildcard libs/*/*.jar))" -XDignore.symbol.file -implicit:none

# SDL3 sources must compile against the core of the newest build that ships SDL.
# Do NOT include the older lwjgl dirs here, otherwise their
# org.lwjgl.system.Configuration/JNI classes can shadow the newer APIs.
SDL_VERSION := $(lastword $(LWJGL_SDL_VERSIONS))
SDL_JCFLAGS := -cp "$(subst $() $(),:,$(wildcard $(SOURCEDIR)/*/):$(wildcard libs/lwjgl-$(SDL_VERSION)/*.jar))" -XDignore.symbol.file -implicit:none

all: $(TARGETS) $(LWJGL_JARS)

# Sometimes the CI produces empty class file resulting in broken jar, so we check and abort here
check_empty_classes:
	@set -e
	@echo "Checking for empty class files"
	$(eval EMPTY_CLASSES := $(shell find $(OUTPUTDIR) -name '*.class' -size 0))
	@if [ -n "$(EMPTY_CLASSES)" ]; then \
		echo "Error: found empty class files in $@: $(EMPTY_CLASSES)"; \
		exit 1; \
	fi

# Rules for building java class
$(CLASSES): $(OUTPUTDIR)/%.class: $(SOURCEDIR)/%.java
	@set -e
	$(eval TARGET=$(word 2, $(subst /, ,$@)))
	@mkdir -p $(OUTPUTDIR)/classes
	@mkdir -p $(dir $@)
	@echo "Compiling $<"
	@if [[ "$<" == $(SOURCEDIR)/lwjgl/org/lwjgl/sdl/* ]]; then \
		echo "Using LWJGL $(SDL_VERSION) classpath for SDL3: $<"; \
		$(BOOTJDK)/javac $(SDL_JCFLAGS) -d $(OUTPUTDIR)/classes $<; \
	else \
		$(BOOTJDK)/javac $(JCFLAGS) -d $(OUTPUTDIR)/classes $<; \
	fi
	@cp $(@:$(OUTPUTDIR)/$(TARGET)/%.class=$(OUTPUTDIR)/classes/%*.class) $(dir $@)/

$(OUTPUTDIR)/launcher.jar: $(CLASSES) check_empty_classes
	@set -e
	@echo "Creating $@"
	@$(BOOTJDK)/jar -cf $@ -C $(basename $@) .

# one fat jar per bundled version: its lwjgl jars plus our classes from src/lwjgl
define LWJGL_JAR_RULE
$$(OUTPUTDIR)/lwjgl-$(1).jar: $$(CLASSES) check_empty_classes
	@set -e
	@echo "Creating $$@"
	@mkdir -p $$(OUTPUTDIR)/lwjgl_lib_$(1)
	@cd $$(OUTPUTDIR)/lwjgl_lib_$(1) && find ../../libs/lwjgl-$(1) -name 'lwjgl*.jar' -exec $$(BOOTJDK)/jar -xf {} \;
	@rm -rf $$(OUTPUTDIR)/lwjgl_lib_$(1)/META-INF
	@cp -R $$(OUTPUTDIR)/lwjgl/. $$(OUTPUTDIR)/lwjgl_lib_$(1)/
	@$$(BOOTJDK)/jar -cf $$@ -C $$(OUTPUTDIR)/lwjgl_lib_$(1) .
endef
$(foreach version,$(LWJGL_VERSIONS),$(eval $(call LWJGL_JAR_RULE,$(version))))

$(OUTPUTDIR)/patchjna_agent.jar: $(CLASSES)
	@set -e
	@mv $(basename $@)/com/sun/jna/Platform.class $(basename $@)/com/sun/jna/Platform.class.patch
	@echo "Creating $@"
	@$(BOOTJDK)/jar -cfm $@ $(SOURCEDIR)/patchjna_agent.txt -C $(basename $@) .

clean:
	rm -rf $(OUTPUTDIR)

.SUFFIXES: .java
.PHONY: all clean

 
$(OUTPUTDIR)/patchsvc.jar: $(CLASSES)
	@set -e
	@mv $(basename $@)/de/maxhenkel/lame4j/Mp3Decoder.class $(basename $@)/de/maxhenkel/lame4j/Mp3Decoder.class.patch
	@mv $(basename $@)/de/maxhenkel/lame4j/Mp3Encoder.class $(basename $@)/de/maxhenkel/lame4j/Mp3Encoder.class.patch
	@mv $(basename $@)/de/maxhenkel/opus4j/OpusDecoder.class $(basename $@)/de/maxhenkel/opus4j/OpusDecoder.class.patch
	@mv $(basename $@)/de/maxhenkel/opus4j/OpusEncoder.class $(basename $@)/de/maxhenkel/opus4j/OpusEncoder.class.patch
	@mv $(basename $@)/de/maxhenkel/rnnoise4j/Denoiser.class $(basename $@)/de/maxhenkel/rnnoise4j/Denoiser.class.patch
	@mv $(basename $@)/de/maxhenkel/speex4j/AutomaticGainControl.class $(basename $@)/de/maxhenkel/speex4j/AutomaticGainControl.class.patch
	@rm -rf $(basename $@)/de/maxhenkel/*/*.class
	@echo "Creating $@"
	@$(BOOTJDK)/jar -cfm $@ $(SOURCEDIR)/patchsvc.txt -C $(basename $@) .
