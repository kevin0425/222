#include <opencv2/opencv.hpp>
#include <chrono>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include <iostream>

#ifdef __ANDROID__
#include <android/log.h>
#endif

using namespace cv;
using namespace std;


long long int get_now() {
    return chrono::duration_cast<std::chrono::milliseconds>(
            chrono::system_clock::now().time_since_epoch()
    ).count();
}

void platform_log(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
#ifdef __ANDROID__
    __android_log_vprint(ANDROID_LOG_VERBOSE, "ndk", fmt, args);
#else
    vprintf(fmt, args);
#endif
    va_end(args);
}
int count_shape = 0;
void print(Mat imgDil, Mat img){

    vector<vector<Point>> contours;
    	vector<Vec4i> hierarchy;


    	findContours(imgDil, contours, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
    	//drawContours(img, contours, -1, Scalar(255, 0, 255), 2);

    	vector<vector<Point>> conPoly(contours.size());
    	vector<Rect> boundRect(contours.size());

    	for (int i = 0; i < contours.size(); i++)
    	{
    		int area = contourArea(contours[i]);
    		//cout << "Area:" + area << endl;
    		string objectType;


    		if (area > 1000)
    		{
    			float peri = arcLength(contours[i], true);
    			approxPolyDP(contours[i], conPoly[i], 0.02 * peri, true);
    			cout << conPoly[i].size() << endl;
    			boundRect[i] = boundingRect(conPoly[i]);

    			int objCor = (int)conPoly[i].size();
    			if (objCor == 3) { objectType = "Tri"; }
    			else if (objCor == 4)
    			{
    				float aspRatio = (float)boundRect[i].width / (float)boundRect[i].height;
    				//cout << aspRatio << endl;
    				if (aspRatio > 0.95 && aspRatio < 1.05) { objectType = "Square"; }
    				else { objectType = "Rect"; }
    			}
    			else if (objCor > 4 && objCor < 8) { objectType = "Oval"; }
    			else if (objCor >= 8) { objectType = "Circle"; }
    			drawContours(img, conPoly, i, Scalar(255, 0, 255), 2);
    			rectangle(img, boundRect[i].tl(), boundRect[i].br(), Scalar(0, 255, 0), 0);
    			putText(img, objectType, { boundRect[i].x,boundRect[i].y - 5 }, FONT_HERSHEY_PLAIN, 10, Scalar(0, 69, 255), 10);

    		}
    	}
}

// Avoiding name mangling
extern "C" {
    // Attributes to prevent 'unused' function from being removed and to make it visible
    __attribute__((visibility("default"))) __attribute__((used))

    const char* version() {
        return CV_VERSION;
    }

    __attribute__((visibility("default"))) __attribute__((used))

    string correct = "Correct";
    string wrong = "Wrong";
    int numberOfPill = 0;

    class Pill {
        public:
            int number;
            string shape;
            Scalar scalar_mean;
            int getNumber(){
                return this->number;
            };
            string getShape(){
                return this->shape;
            };
            Scalar getScalar(){
                return this->scalar_mean;
            };
            Pill(int number, string shape, Scalar scalar_mean){
                this->number = number;
                this->shape = shape;
                this->scalar_mean = scalar_mean;
            }
    };

    void getContours(Mat imgDil, Mat img){
    }



    void process_image(char* inputImagePath, char* outputImagePath) {
        long long start = get_now();

        //initialization
        Mat img = imread(inputImagePath);
        Mat threshed, withContours;
        Mat imgGray, imgBlur, imgCanny, imgDil, imgErode;
        vector<vector<Point>> contours;
        vector<Vec4i> hierarchy;

        Pill pill1(1, "Circle", Scalar(113.419649, 138.77447, 191.353908));
        Pill pill2(2, "Circle", Scalar(139.4175, 139.8383, 106.1375));
        Pill pill3(3, "Circle", Scalar(147.475197, 157.593769,168.391712));
        Pill testpill(3, "Circle", Scalar(113.419649,  138.77447, 250.353908));

        cvtColor(img, imgGray, COLOR_BGR2GRAY);
        GaussianBlur(imgGray, imgBlur, Size(3, 3), 3, 0);
        Canny(imgBlur, imgCanny, 25, 75);

        Mat kernel = getStructuringElement(MORPH_RECT, Size(3, 3));
        dilate(imgCanny, imgDil, kernel);

        // adaptiveThreshold(input, threshed, 255, ADAPTIVE_THRESH_GAUSSIAN_C, THRESH_BINARY_INV, 77, 6);
        // findContours(threshed, contours, hierarchy, RETR_TREE, CHAIN_APPROX_TC89_L1);
        findContours(imgDil, contours, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
        // cvtColor(threshed, withContours, COLOR_GRAY2BGR);
        // drawContours(withContours, contours, -1, Scalar(0, 255, 0), 4);
        // drawContours(img, contours, -1, Scalar(255, 0, 255), 2);
        Mat resImage0 = img.clone();
        Mat resImage1 = img.clone();

        vector<vector<Point>> cornerPoly(contours.size());
        vector<Rect> boundRect(contours.size());
        string objShape [10];
        for(int i=0; i<contours.size(); i++){
            int area = contourArea(contours[i]);


            if(area > 1000)
            {

                float peri = arcLength(contours[i], true); //the bounding box
                approxPolyDP(contours[i], cornerPoly[i], 0.02*peri, true);//the number of curves/sides

                boundRect[i] = boundingRect(cornerPoly[i]);
                //test color
                Rect _boundingRect = boundingRect(contours[i]);
                Scalar color=Scalar(0, 0, 255);
                Scalar mean_color0 = mean(img(_boundingRect));
                Scalar mean_color1 = mean(img(_boundingRect), imgGray(_boundingRect));
                numberOfPill += 1;
                drawContours(resImage0, contours, i, mean_color0, FILLED);
                drawContours(img, contours, i, testpill.getScalar(), FILLED);
                //end of test color
                int objEdge= (int)cornerPoly[i].size();
                if(objEdge>=8)
                {
                    objShape[count_shape] = "Circle";
                    count_shape++;
                }
                else if(objEdge<8 && objEdge > 4)
                {
                    objShape[count_shape] = "Oval";
                    count_shape++;
                }
                drawContours(img, cornerPoly, i, Scalar(255, 0, 255), 3);
                rectangle(img, boundRect[i].tl(), boundRect[i].br(),Scalar(0, 255, 0), 5);
                String scalar_val = to_string(mean_color1.val[0]) + " "+ to_string(mean_color1.val[1])+" "+to_string(mean_color1.val[2]);
                putText(img, to_string(numberOfPill) ,{boundRect[i].x, boundRect[i].y-5}, FONT_HERSHEY_DUPLEX, 10, Scalar(0, 69, 255), 10);

            }
        }
        if(objShape[0] == "Circle"){
            putText(img, "www", Point(200, 450), FONT_HERSHEY_DUPLEX, 10, CV_RGB(118, 185, 0), 10);
        }
        if(numberOfPill == testpill.number){
            putText(img, "correct", Point(10, 450), FONT_HERSHEY_DUPLEX, 10, CV_RGB(118, 185, 0), 10);
        }else{
            putText(img, "wrong", Point(10, 450), FONT_HERSHEY_DUPLEX, 10, CV_RGB(118, 185, 0), 10);
        }
        /////////////////////////////////////////////////////////////

        imwrite(outputImagePath, img);

        int evalInMillis = static_cast<int>(get_now() - start);
        platform_log("Processing done in %dms\n", evalInMillis);
    }
}