/// تقييد القيم ضمن مدى، مع ضمان نوع النتيجة (double / int).
double clampD(double value, double min, double max) =>
    value < min ? min : (value > max ? max : value);

int clampI(int value, int min, int max) =>
    value < min ? min : (value > max ? max : value);
