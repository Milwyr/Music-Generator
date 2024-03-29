class AudioSamples {

    public float duration;
    public int samplingRate;
    public int totalSamples;
    public float[] leftChannelSamples;
    public float[] rightChannelSamples;

    // Constructor
    AudioSamples(float duration, int samplingRate) {
        this.duration = duration;
        this.samplingRate = samplingRate;

        totalSamples = int(duration * samplingRate);
        leftChannelSamples = new float[totalSamples];
        rightChannelSamples = new float[totalSamples];

        clear();
    }

    public void add(AudioSamples other, float stereoPosition, float startPosition) {
        add(other, stereoPosition, startPosition, other.duration);
    }

    // Add anohter AudioSamples to this
    // The input parameters are:
    // - another AudioSamples that to be added to this AudioSamples
    // - the stereo position, in the range [0, 1]. 0 means left only, 0.5 is in the middle and 1 means right only.
    // - the start time, in seconds
    // - the duration, in seconds
    public void add(AudioSamples other, float stereoPosition, float startPosition, float duration) {
        // In this function we add the individual sound samples to the complete music sequence samples.
        // Another way to think about it is that we are adding a single musical note to the complete music sequence.

        int startSample = int(startPosition * samplingRate);
        int samplesToCopy = int(duration * samplingRate);

        if(startSample >= totalSamples) return;

        float leftVol = 1.0 - stereoPosition;
        float rightVol = stereoPosition;

        for(int i = startSample, j = 0; i < totalSamples && j < samplesToCopy; ++i, ++j) {
            leftChannelSamples[i] += leftVol * other.leftChannelSamples[j];
            rightChannelSamples[i] += rightVol * other.rightChannelSamples[j];
        }
    }

    // Clear all samples by setting them to 0
    public void clear() {
        for(int i = 0; i < totalSamples; ++i) {
            leftChannelSamples[i] = rightChannelSamples[i] = 0;
        }
    }

    // Transform the samples to a specified range of amplitude
    private void reMap(float sourceRangeMin, float sourceRangeMax, float destinationRangeMin, float destinationRangeMax) {
        float sourceRange = sourceRangeMax - sourceRangeMin;
        float destinationRange = destinationRangeMax - destinationRangeMin;
        float factor = destinationRange / sourceRange;
        for(int i = 0; i < totalSamples; ++i) {
            leftChannelSamples[i] = destinationRangeMin + (leftChannelSamples[i] - sourceRangeMin) * factor;
            rightChannelSamples[i] = destinationRangeMin + (rightChannelSamples[i] - sourceRangeMin) * factor;
        }
    }

    // The following 4 functions apply post processing to this AudioSamples
    void applyPostProcessing(int postprocess) {
        postprocessEffect(2, postprocess, float(""), float(""));
    }

    void applyPostProcessing(int channel, int postprocess) {
        postprocessEffect(channel, postprocess, float(""), float(""));
    }

    void applyPostProcessing(int channel, int postprocess, float param1) {
        postprocessEffect(channel, postprocess, param1, float(""));
    }

    void applyPostProcessing(int channel, int postprocess, float param1, float param2) {
        postprocessEffect(channel, postprocess, param1, param2);
    }

    // Apply post processing to this AudioSamples, on the specified channel(s)
    // target:
    // - 0 left channel only
    // - 1 right channel only
    // - 2 both channels
    void postprocessEffect(int target, int postprocess, float param1, float param2) {
        // Do nothing if the target is not valid
        if(target < 0 || target > 2) {
            return;
        }

        switch (postprocess) {
            case (1): break; // Nothing is done to the sound
            case (2): applyExponentialDecay(target, param1, param2); break; // Exponential decay
            case (3): applyLowPassFilter(target, param1, param2); break; // Low pass filter
            case (4): applyBandRejectFilter(target, param1, param2); break; // Band reject filter
            case (5): applyFadeIn(target, param1, param2); break; // Linear fade in
            case (6): applyReverse(target, param1, param2); break; // Reverse
            case (7): applyBoost(target, param1, param2); break; // Boost
            case (8): applyTremolo(target, param1, param2); break; // Tremolo
            case (9): applyEcho(target, param1, param2); break; // Echo
            case(10): break; // You can add your own post processing if you want to
        }
    }

    // Apply exponential decay
    private void applyExponentialDecay(int target, float param1, float param2) {

        // Set up the target(s)
        float[] input = new float[0];
        float[] input2 = new float[0];
        switch(target) {
            case(0): input = leftChannelSamples; break;
            case(1): input = rightChannelSamples; break;
            case(2): input = leftChannelSamples; input2 = rightChannelSamples; break;
        }

        float timeConstant = 0.2;  // decay constant, see PDF notes for explanation
        if (!Float.isNaN(param1)) {
            timeConstant = param1;
        }

        for (int i = 0; i < input.length; ++i) {
            float currentTime = float(i) / samplingRate;
            float decayMultiplier = (float) Math.exp(-1 * currentTime / timeConstant);
            input[i] = input[i] * decayMultiplier;

            // Handle the second channel if needed
            if (input2.length > 0) {
                input2[i] = input2[i] * decayMultiplier;
            }
        }
    }

    // Apply low pass filter
    private void applyLowPassFilter(int target, float param1, float param2) {

        // Set up the target(s)
        float[] input = new float[0];
        float[] input2 = new float[0];
        switch(target) {
            case(0): input = leftChannelSamples; break;
            case(1): input = rightChannelSamples; break;
            case(2): input = leftChannelSamples; input2 = rightChannelSamples; break;
        }

        /*** Complete this function if your student id ends in an odd number ***/
        float[] output = new float[totalSamples];
        float[] output2 = new float[totalSamples];


        for (int i = 1; i < input.length; i++) {
            output[i] = 0.5 * (input[i - 1] + input[i]);
            output2[i] = 0.5 * (input2[i - 1] + input2[i]);
        }

        input = output;
        input2 = output2;
    }

    // Apply band reject filter
    private void applyBandRejectFilter(int target, float param1, float param2) {

        // Set up the target(s)
        float[] input = new float[0];
        float[] input2 = new float[0];
        switch(target) {
            case(0): input = leftChannelSamples; break;
            case(1): input = rightChannelSamples; break;
            case(2): input = leftChannelSamples; input2 = rightChannelSamples; break;
        }

        /*** Complete this function if your student id ends in an even number ***/
    }

    // Apply linear fade in
    private void applyFadeIn(int target, float param1, float param2) {

        // Set up the target(s)
        float[] input = new float[0];
        float[] input2 = new float[0];
        
        switch(target) {
            case(0): input = leftChannelSamples; break;
            case(1): input = rightChannelSamples; break;
            case(2): input = leftChannelSamples; input2 = rightChannelSamples; break;
        }

        float fadeValue = 2.0;  // fade in duration in seconds
        if(!Float.isNaN(param1)) {
            fadeValue = param1;
        }

        /*** Complete this function ***/
        int totalSamplesToFade = int(fadeValue * samplingRate);

        // Ensure totalSamplesToFade does not exceed total samples
        if (totalSamplesToFade > input.length) {
            totalSamplesToFade = input.length;
        }

        for (int i = 0; i < totalSamplesToFade; i++) {
            float fadeMultiplier = i / totalSamplesToFade;
            input[i] *= fadeMultiplier;

            if (input2.length > 0) {
                input2[i] *= fadeMultiplier;
            }
        }
    }

    // Apply reverse
    private void applyReverse(int target, float param1, float param2) {

        // Set up the target(s)
        float[] input = new float[0];
        float[] input2 = new float[0];
        switch(target) {
            case(0): input = leftChannelSamples; break;
            case(1): input = rightChannelSamples; break;
            case(2): input = leftChannelSamples; input2 = rightChannelSamples; break;
        }

        float temp;

        for (int i = 0; i < (input.length - 1) / 2; i++) {
            temp = input[i];
            input[i] = input[input.length - 1 - i];
            input[input.length - 1 - i] = temp;
            
            if (input2.length > 0) {
                temp = input2[i];
                input2[i] = input2[input2.length - 1 - i];
                input2[input2.length - 1 - i] = temp;
            }
        } 
    }

    // Apply boost
    private void applyBoost(int target, float param1, float param2) {

        // Set up the target(s)
        float[] input = new float[0];
        float[] input2 = new float[0];
        switch(target) {
            case(0): input = leftChannelSamples; break;
            case(1): input = rightChannelSamples; break;
            case(2): input = leftChannelSamples; input2 = rightChannelSamples; break;
        }

        float boostMax = -1.0; // set a low starting value for the max
        float boostMin = 1.0;  // set a high starting value for the min

        // Find the max and min boost value in the input array
        for (int i = 0; i < input.length; i++) {
            if (boostMax < input[i]) {
                boostMax = input[i];
            }
            
            if (boostMin > input[i]) {
                boostMin = input[i];
            }
        }

        boostMin = -1 * boostMin;
        float biggest = max(boostMax, boostMin);
        float boostMultiplier = 1 / biggest; // maximum value = 1

        for (int i = 0; i < input.length; i++) {
            input[i] *= boostMultiplier;
            
            if (input2.length > 0) {
                input2[i] *= boostMultiplier;
            }
        }
    }

    // Apply tremolo
    private void applyTremolo(int target, float param1, float param2) {

        // Set up the target(s)
        float[] input = new float[0];
        float[] input2 = new float[0];
        switch(target) {
            case(0): input = leftChannelSamples; break;
            case(1): input = rightChannelSamples; break;
            case(2): input = leftChannelSamples; input2 = rightChannelSamples; break;
        }

        float tremoloFrequency = 10; // Frequency of the tremolo effect, change as appropriate
        if(!Float.isNaN(param1)) {
            tremoloFrequency = param1;
        }
        float wetness = 0.5;
        if(!Float.isNaN(param2)) {
            wetness = param2;
        }

        // Multiply by a sine wave in range between 0 and 1
        for (int i = 0; i < input.length - 1; i++) {
            float currentTime = float(i) / samplingRate;
            input[i] *= (sin(TWO_PI * tremoloFrequency * currentTime) + 1) / 2;
            input2[i] *= (sin(TWO_PI * tremoloFrequency * currentTime) + 1) / 2;
        }
    }

    // Apply echo
    private void applyEcho(int target, float param1, float param2) {
        // You can find pseudo-code for this in the PDF file.
        // You only need to handle one delay line for this project.

        // Set up the target(s)
        float[] input = new float[0];
        float[] input2 = new float[0];
        switch(target) {
            case(0): input = leftChannelSamples; break;
            case(1): input = rightChannelSamples; break;
            case(2): input = leftChannelSamples; input2 = rightChannelSamples; break;
        }

        float delayLineDuration = 0.15; // Length of delay line, in seconds

        if(!Float.isNaN(param1)) {
            delayLineDuration = param1;
        }

        // Need to declare the multiplier for the delay line(s) (just one delay line in this example code)
        float delayLineMultiplier = 0.5;

        if(!Float.isNaN(param2)) {
            delayLineMultiplier = param2;
        }

        // TODO: Finish this function correctly
        int delayLineLength = (int) Math.floor(delayLineDuration * samplingRate);

        float[] delayLineSample = new float[delayLineLength];

        // Initialise the float array delayLineSample with the value 0
        for (int i = 0; i < delayLineLength; i++) {
            delayLineSample[i] = 0.0f;
        }

        // A temporary output to store the value of delay line
        float delayLineOutput;

        int clippingCount = 0;

        for (int i = 0; i < input.length - 1; i++) {
            // Extract the appropriate value from each of the delay lines,
            // and add it to the original input sound later
            if (i >= delayLineLength) {
                delayLineOutput = delayLineSample[i % delayLineLength];
            } else {
                delayLineOutput = 0;
            }

            input[i] += (float) (delayLineOutput * delayLineMultiplier);

            // Count the number of clippings 
            if ((input[i] > 1.0) || (input[i] < -1.0)) {
                clippingCount++;
            }

            delayLineSample[i % delayLineLength] = input[i];

            if (clippingCount > 0) {
                println(clippingCount + " samples have been clipped... result is invalid");
            }
        }
    }
}