package com.congcq.patchsvc;

import java.io.*;
import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.Instrumentation;
import java.security.ProtectionDomain;

public class PatchSVC implements ClassFileTransformer {

    private static final String[][] PATCHES = {
        {"de/maxhenkel/rnnoise4j/Denoiser", "de/maxhenkel/rnnoise4j/Denoiser.class.patch"},
        {"de/maxhenkel/opus4j/OpusDecoder", "de/maxhenkel/opus4j/OpusDecoder.class.patch"},
        {"de/maxhenkel/opus4j/OpusEncoder", "de/maxhenkel/opus4j/OpusEncoder.class.patch"},
        {"de/maxhenkel/lame4j/Mp3Decoder", "de/maxhenkel/lame4j/Mp3Decoder.class.patch"},
        {"de/maxhenkel/lame4j/Mp3Encoder", "de/maxhenkel/lame4j/Mp3Encoder.class.patch"},
        {"de/maxhenkel/speex4j/AutomaticGainControl", "de/maxhenkel/speex4j/AutomaticGainControl.class.patch"},
    };

    @Override
    public byte[] transform(ClassLoader loader, String className,
                            Class<?> classBeingRedefined,
                            ProtectionDomain protectionDomain,
                            byte[] classfileBuffer) {

        String patchFile = getPatchFile(className);
        if (patchFile == null) {
            return classfileBuffer;
        }

        System.out.println("PatchSVC: Replacing class " + className);

        try {
            InputStream inputStream = PatchSVC.class.getClassLoader().getResourceAsStream(patchFile);
            if (inputStream == null) {
                System.err.println("PatchSVC: ERROR - Patch file not found: " + patchFile);
                return classfileBuffer;
            }

            // Do not rely on InputStream.available(): jar-backed streams are allowed
            // to report only currently buffered bytes, which can produce truncated
            // replacement classes and make the voice-chat codec module fail to load.
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            byte[] buffer = new byte[8192];
            int count;
            try {
                while ((count = inputStream.read(buffer)) != -1) {
                    outputStream.write(buffer, 0, count);
                }
            } finally {
                inputStream.close();
            }
            byte[] patched = outputStream.toByteArray();
            if (patched.length < 8 || patched[0] != (byte) 0xCA ||
                    patched[1] != (byte) 0xFE || patched[2] != (byte) 0xBA ||
                    patched[3] != (byte) 0xBE) {
                System.err.println("PatchSVC: ERROR - Invalid replacement class for " + className
                        + " (" + patched.length + " bytes)");
                return classfileBuffer;
            }

            System.out.println("PatchSVC: SUCCESS - Patched " + className
                    + " (" + patched.length + " bytes)");
            return patched;

        } catch (Exception e) {
            System.err.println("PatchSVC: ERROR - " + e.getMessage());
            e.printStackTrace();
            return classfileBuffer;
        }
    }

    private String getPatchFile(String className) {
        for (String[] patch : PATCHES) {
            if (patch[0].equals(className)) {
                return patch[1];
            }
        }
        return null;
    }

    public static void premain(String args, Instrumentation instrumentation) {
        System.out.println("PatchSVC: premain called");
        String bundle = System.getenv("BUNDLE_PATH");
        if (bundle == null || bundle.isEmpty()) {
            System.err.println("PatchSVC: ERROR - BUNDLE_PATH is not set; native codec libraries cannot be located");
        } else {
            String[] libraries = {
                "libopus4j.dylib",
                "liblame4j.dylib",
                "librnnoise4j.dylib",
                "libspeex4j.dylib"
            };
            File codecDir = new File(bundle, "Frameworks/svc");
            System.out.println("PatchSVC: codec directory=" + codecDir.getAbsolutePath()
                    + " exists=" + codecDir.isDirectory());
            for (String library : libraries) {
                File file = new File(codecDir, library);
                System.out.println("PatchSVC: codec " + library + " exists=" + file.isFile()
                        + " readable=" + file.canRead()
                        + " bytes=" + (file.isFile() ? file.length() : 0));
            }
        }
        instrumentation.addTransformer(new PatchSVC());
    }
}