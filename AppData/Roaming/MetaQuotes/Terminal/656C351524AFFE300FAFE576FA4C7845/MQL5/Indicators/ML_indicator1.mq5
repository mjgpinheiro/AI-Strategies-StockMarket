//+------------------------------------------------------------------------------------------------------------------------------------+
//|                                                ML_indicator1.mq5                                                                   |
//|                                              Copyright 2023, MJP                                                                   | 
//|                                             https://www.mql5.com                                                                   |
//| Note for users: This code completes the implementation of loading the linear regression model's parameters and making predictions. |
//| It uses the predicted close price to generate buy and sell signals. The offset value determines the distance between the arrow and |
//| the high/low of the current bar. You can adjust the offset by changing the value 10 to your preferred value in points. See also    |
//| additionale instructions at the end                                                                                                |
//+------------------------------------------------------------------------------------------------------------------------------------+
#property copyright "Copyright 2023, MJP"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_type1 DRAW_ARROW
#property indicator_color1 clrGreen
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2

// Buy signal properties
#property indicator_type1 DRAW_ARROW
#property indicator_color1 clrGreen

// Sell signal properties
#property indicator_type2 DRAW_ARROW
#property indicator_color2 clrRed

double BuySignal[];
double SellSignal[];

// Model parameters
double Coefficients[];
double Intercept;
double Mean[];
double Scale[];

int OnInit() {
  SetIndexBuffer(0, BuySignal, INDICATOR_DATA);
  SetIndexBuffer(1, SellSignal, INDICATOR_DATA);
  
  PlotIndexSetInteger(0, PLOT_ARROW, 233); // Use an arrow symbol for the buy signal
  PlotIndexSetInteger(1, PLOT_ARROW, 234); // Use an arrow symbol for the sell signal
  
  // Load model parameters from CSV file
  string model_params_file = "model_params.csv";
if (FileIsExist(model_params_file)) {
    int file_handle = FileOpen(model_params_file, FILE_READ | FILE_CSV);
    if (file_handle != INVALID_HANDLE) {
for (int i = 0; i < 2; i++) {
  ArrayResize(Coefficients, 2);
  ArrayResize(Mean, 2);
  ArrayResize(Scale, 2);
  
  Coefficients[i] = FileReadNumber(file_handle);
}
Intercept = FileReadNumber(file_handle);
for (int i = 0; i < 2; i++) {
  Mean[i] = FileReadNumber(file_handle);
}
for (int i = 0; i < 2; i++) {
  Scale[i] = FileReadNumber(file_handle);
}
FileClose(file_handle);

    } else {
      Print("Error opening the model parameters file.");
      return (INIT_FAILED);
    }
  } else {
    Print("Model parameters file not found.");
    return (INIT_FAILED);
  }

  return(INIT_SUCCEEDED);
}

double Predict(double SMA_5, double SMA_10) {
  double X[2] = {SMA_5, SMA_10};
  
  // Standardize the input data
  for (int i = 0; i < 2; i++) {
    X[i] = (X[i] - Mean[i]) / Scale[i];
  }

  // Calculate the prediction using the linear regression model
  double prediction = Intercept;
  for (int i = 0; i < 2; i++) {
    prediction += Coefficients[i] * X[i];
  }

  return prediction;
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[]) {
  int startBar = prev_calculated - 1;

  for (int i = startBar; i < rates_total; i++) {
    BuySignal[i] = EMPTY_VALUE;
    SellSignal[i] = EMPTY_VALUE;

    // Calculate features for the current bar
    double SMA_5 = iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_CLOSE);
    double SMA_10 = iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE);

    // Get prediction from the model
    double prediction = Predict(SMA_5, SMA_10);

    // Buy condition: predicted price is higher than the current price
    if (prediction > close[i]) {
      BuySignal[i] = low[i] - (10 * _Point); // Replace 10 with your preferred offset value in points
    }

    // Sell condition: predicted price is lower than the current price
    if (prediction < close[i]) {
      SellSignal[i] = high[i] + (10 * _Point); // Replace 10 with your preferred offset value in points
    }
  }

  return(rates_total);
}
//+------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Unfortunately, it's not possible to run Python code directly from MQL5. However, you can use Python to preprocess your data and save the model parameters  |
//| to a CSV file, which you can then read in MQL5.                                                                                                            |
//| Follow these steps to run the Python code and use the output in MQL5:                                                                                      |
//| Run the Python code provided in your Python environment or IDE. This code will save the model parameters (coefficients, intercept, mean, and scale) in a   |
//| CSV file named "model_params.csv."                                                                                                                         |
//| Copy the "model_params.csv" file to the "Files" folder within your MetaTrader 5 installation directory.                                                    |
//| The path is usually: "C:\Program Files\MetaTrader 5\MQL5\Files".                                                                                           |
//| In the MQL5 code I provided earlier, the OnInit() function reads the model parameters from the "model_params.csv" file. Make sure the filename in the MQL5 |
//| code matches the one you saved from the Python code.                                                                                                       |
//| Please note that to execute Python code, you need to have Python installed on your machine, along with the required libraries (pandas, scikit-learn,       |
//| and numpy). You can install these libraries using pip:                                                                                                     |
//! Copy code                                                                                                                                                  |
//| pip install pandas numpy scikit-learn                                                                                                                      |
//| After running the Python code and saving the model parameters to a CSV file, you can use the MQL5 code to read the parameters and make predictions based   |
//| on the trained linear regression model.                                                                                                                    |
//+------------------------------------------------------------------------------------------------------------------------------------------------------------+