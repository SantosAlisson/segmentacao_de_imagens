void desenharGrafico(int vp, int fp, int fn, int vn) {
    int yBase = 550;
    int maxVal = max(vp, fp, fn);
    float scaleFactor = 200.0 / maxVal; 

    fill(0, 255, 0);  // Verde para vp
    rect(50, yBase, 50, -vp * scaleFactor);
    fill(255, 0, 0);  // Vermelho para fp
    rect(150, yBase, 50, -fp * scaleFactor);
    fill(0, 0, 255);  // Azul para fn
    rect(250, yBase, 50, -fn * scaleFactor);
    fill(128, 128, 128);  // Cinza para vn
    rect(350, yBase, 50, -vn * scaleFactor);
    
    fill(0);
    text("vp", 65, yBase + 15);
    text("fp", 165, yBase + 15);
    text("fn", 265, yBase + 15);
    text("vn", 365, yBase + 15);
}

void calcularMetricas(PImage imgSegmentada, PImage groundTruth) {
    imgSegmentada.loadPixels();
    groundTruth.loadPixels();

    int vp = 0, fp = 0, fn = 0, vn = 0;

    for (int i = 0; i < imgSegmentada.pixels.length; i++) {
        boolean segmentado = (brightness(imgSegmentada.pixels[i]) > 210); 
        boolean real = (brightness(groundTruth.pixels[i]) > 210);  // mesmo limiar para o ground truth

        if (segmentado && real) vp++;
        else if (segmentado && !real) fp++;
        else if (!segmentado && real) fn++;
        else if (!segmentado && !real) vn++;
    }

    println("Verdadeiros Positivos (vp): " + vp);
    println("Falsos Positivos (fp): " + fp);
    println("Falsos Negativos (fn): " + fn);
    println("Verdadeiros Negativos (vn): " + vn);

    desenharGrafico(vp, fp, fn, vn);
}
