// extra libraries:
// - https://github.com/nickgammon/Regexp
// - https://www.dfrobot.com.cn//images/upload/File/201709141149593byvtx.zip

#include <Arduino.h>
#include <Regexp.h>
#include <dht11.h>

#define CANCEL_CHAR  30

#define MOISTURE_PIN A2
#define DHT11_PIN    9
#define PUMP_PIN_1   5
#define PUMP_PIN_2   6

class Pump {
    bool working = false;

    bool _auto = false;
    double autoMin = 1;
    double autoMax = 30;

  public:
    void pumpOn(int duration = 0)
    {
      working = true;
      digitalWrite(PUMP_PIN_1, HIGH);
      digitalWrite(PUMP_PIN_2, HIGH);

      if (duration > 0) {
        delay(duration);
        pumpOff();
      }
    }

    void pumpOff()
    {
      working = false;
      digitalWrite(PUMP_PIN_1, LOW);
      digitalWrite(PUMP_PIN_2, LOW);
    }

    void performAuto() {
      while (_auto && checkMoisture()) {
        pumpOn(1000);
      }
    }

    bool getWorking() {
      return working;
    }

    bool getAuto() {
      return _auto;
    }

    void setAuto(bool _auto) {
      this->_auto = _auto;
      return this;
    }

    double getAutoMin() {
      return autoMin;
    }

    void setAutoMin(double autoMin) {
      this->autoMin = autoMin;
      return this;
    }

    double getAutoMax() {
      return autoMax;
    }

    void setAutoMax(double autoMax) {
      this->autoMax = autoMax;
      return this;
    }

  protected:
    bool checkMoisture() {
      int moisture = analogRead(MOISTURE_PIN);
      double maxMoisture = 950.0;

      double percentage = (moisture / maxMoisture) * 100;

      return (percentage >= autoMin && percentage <= autoMax);
    }
};

Pump pump;

class HttpServer {
    String request;
    String response;
    dht11 DHT;

  public:
    void readRequest() {
      this->request = "";

      char c = NULL;
      do {
        c = Serial.read();

        if (c == '\n') {
          break;
        }

        if (c == CANCEL_CHAR) {
          this->request = "";
          this->response = '\n';
          break;
        }

        this->request += c;
      } while (true);
    }

    void processRequest() {
      if (!this->request.length()) {
        return;
      }

      String method = this->getMethod();
      String route = this->getRoute();

      method.toUpperCase();

      if (!this->checkMehtod(method)) {
        this->response = String("{\"code\":500,\"status\":\"Check method failure.\"}");
        return;
      }

      if (!this->checkRoute(route)) {
        this->response = String("{\"code\":500,\"status\":\"Check route failure.\"}");
        return;
      }

      if (method == "GET") {
        return this->processGet(route);
      } else if (method == "POST") {
        return this->processPost(route);
      }
    }

    void sendResponse() {
      if (this->response.length()) {
        Serial.println(response);
      }
    }

  protected:
    bool isRequestEmtpy() {
      return (bool) this->request.length();
    }

    String getMethod() {
      String result = "";

      MatchState ms;
      char buf [100];
      ms.Target(this->request.c_str());
      char res = ms.Match ("(.*) (.*)", 0);
      switch (res)
      {
        case REGEXP_MATCHED:
          result = ms.GetCapture (buf, 0);
          break;
        case REGEXP_NOMATCH:
          break;
      }

      return result;
    }

    String getRoute() {
      String result = "";

      MatchState ms;
      char buf [100];
      ms.Target(this->request.c_str());
      char res = ms.Match ("(.*) (.*)", 0);
      switch (res)
      {
        case REGEXP_MATCHED:
          result = ms.GetCapture (buf, 1);
          break;
        case REGEXP_NOMATCH:
          break;
      }

      return result;
    }

    bool checkMehtod(const String &method) {
      return (bool) (!method.equals("GET") || !method.equals("POST"));
    }

    bool checkRoute(const String &route) {
      return (bool) route.length();
    }

    void processGet(const String &route) {
      if (route.equals("/moisture")) {
        this->response = String("{\"code\":200,\"status\":\"OK\",\"data\":{\"value\":\"") + analogRead(MOISTURE_PIN) + String("\",\"min\":\"0\",\"max\":\"950\",\"ranges\":[{\"from\":\"0\",\"to\":\"300\",\"title\":\"dry soil\"},{\"from\":\"301\",\"to\":\"700\",\"title\":\"humid soil\"},{\"from\":\"701\",\"to\":\"950\",\"title\":\"in water\"}]}}");
      } else if (route.equals("/temperature")) {
        if (this->waitForDHT(30000)) {
          this->response = String("{\"code\":200,\"status\":\"OK\",\"data\":{\"value\":\"") + this->DHT.temperature + String("\",\"min\":\"-20\",\"max\":\"60\"}}");
        } else {
          return;
        }
      } else if (route.equals("/humidity")) {
        if (this->waitForDHT(30000)) {
          this->response = String("{\"code\":200,\"status\":\"OK\",\"data\":{\"value\":\"") + this->DHT.humidity + String("\",\"min\":\"5\",\"max\":\"95\"}}");
        } else {
          return;
        }
      } else if (route.equals("/pump")) {
        this->response = String("{\"code\":200,\"status\":\"OK\",\"data\":{\"working\":") + pump.getWorking() + String(",\"auto\":") + pump.getAuto() + String(",\"auto_min\":\"") + pump.getAutoMin() + String("\",\"auto_max\":\"") + pump.getAutoMax() + String("\"}}");
      } else {
        this->response = String("{\"code\":500,\"status\":\"Invalid route.\"}");
      }

      return;
    }

    bool checkDHT() {
      int chk;
      chk = this->DHT.read(DHT11_PIN);
      switch (chk) {
        case DHTLIB_OK:
          return true;
        case DHTLIB_ERROR_CHECKSUM:
          this->response = String("{\"code\":500,\"status\":\"DHT - Checksum error.\"}");
          return false;
        case DHTLIB_ERROR_TIMEOUT:
          this->response = String("{\"code\":500,\"status\":\"DHT - Time out error.\"}");
          return false;
        default:
          this->response = String("{\"code\":500,\"status\":\"DHT - Unknown error.\"}");
          return false;
      }
    }

    bool waitForDHT(int maxTimeout) {
      bool DHTReady = false;
      int timeout = 0;

      do {
        int chk;
        chk = this->DHT.read(DHT11_PIN);
        if (chk == DHTLIB_OK) {
          DHTReady = true;
          break;
        }

        timeout += 1000;
        delay(1000);
      } while (timeout < maxTimeout);

      return DHTReady;
    }

    void processPost(const String &route) {
      String rawRoute = getRawRoute(route);
      String queryString = getQueryString(route);

      if (rawRoute.equals("/pump/start")) {
        pump.pumpOn();
        this->response = String("{\"code\":200,\"status\":\"OK\"}");
      } else if (rawRoute.equals("/pump/stop")) {
        pump.pumpOff();
        this->response = String("{\"code\":200,\"status\":\"OK\"}");
      } else if (rawRoute.equals("/pump/auto-pump")) {
        while (true) {
          String queryParam;
          queryParam = this->getNextQueryParam(queryString);

          if (queryParam.length() == 0) {
            break;
          }

          String key = this->getQueryParamKey(queryParam);
          String value = this->getQueryParamValue(queryParam);

          if (key.equals("auto")) {
            pump.setAuto(value.toInt());
          }
        }

        this->response = String("{\"code\":200,\"status\":\"OK\"}");
      } else if (rawRoute.equals("/pump/auto-pump-range")) {
        while (true) {
          String queryParam;
          queryParam = this->getNextQueryParam(queryString);

          if (queryParam.length() == 0) {
            break;
          }

          String key = this->getQueryParamKey(queryParam);
          String value = this->getQueryParamValue(queryParam);

          if (key.equals("min")) {
            pump.setAutoMin(value.toDouble());
          } else if (key.equals("max")) {
            pump.setAutoMax(value.toDouble());
          }
        }

        this->response = String("{\"code\":200,\"status\":\"OK\"}");
      } else {
        this->response = String("{\"code\":500,\"status\":\"Invalid route.\"}");
      }

      return;
    }

    String getRawRoute(const String &route) {
      String result = route;

      int questionMarkPosition = route.indexOf('?');
      if (questionMarkPosition > 0) {
        result = route.substring(0, questionMarkPosition);
      }

      return result;
    }

    String getQueryString(const String &route) {
      String result;

      int questionMarkPosition = route.indexOf('?');
      if (questionMarkPosition > 0) {
        result = route.substring(questionMarkPosition + 1);
      }

      return result;
    }

    String getNextQueryParam(String &queryParams) {
      String result;

      if (queryParams.length()) {
        int ampersandPosition = queryParams.indexOf('&');
        if (ampersandPosition > 0) {
          result = queryParams.substring(0, ampersandPosition);
          queryParams = queryParams.substring(ampersandPosition + 1);
        } else {
          result = queryParams;
          queryParams = "";
        }
      }

      return result;
    }

    String getQueryParamKey(const String &queryParam) {
      String result;

      if (queryParam.length()) {
        int equalsPosition = queryParam.indexOf('=');
        if (equalsPosition > 0) {
          result = queryParam.substring(0, equalsPosition);
        }
      }

      return result;
    }

    String getQueryParamValue(const String &queryParam) {
      String result;

      if (queryParam.length()) {
        int equalsPosition = queryParam.indexOf('=');
        if (equalsPosition > 0) {
          result = queryParam.substring(equalsPosition + 1);
        }
      }

      return result;
    }

};

void setup() {
  Serial.begin(9600);

  pinMode(PUMP_PIN_1, OUTPUT);
  pinMode(PUMP_PIN_2, OUTPUT);

  digitalWrite(PUMP_PIN_1, LOW);
  digitalWrite(PUMP_PIN_2, LOW);
}

void loop() {
  pump.performAuto();
  if (Serial.available()) {
    HttpServer server;
    server.readRequest();
    server.processRequest();
    server.sendResponse();
  }
}
