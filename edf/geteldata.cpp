/* This reads Eyelink 1000 .edf monocular data and outputs some Matlab variables for the data */

#include <stdio.h>
#include <list>
#include <fstream>
#include <vector>
#include <string>
#include "mex.h"
#include "edf.h"
#include "edf_data.h"
#include "edftypes.h"

using namespace std;

#define MAX_STR_LENGTH 256

void mexFunction( int nlhs,mxArray *plhs[],int nrhs, const mxArray *prhs[]) {
	char command[MAX_STR_LENGTH];
	int preambleTextLength;
	char *preambleText;
	EDFFILE *edfid;
	ALLF_DATA *alldat;
	int err;
	int edfdattype;
	double *x;
	double *y;
    int eye;

	// Should be the file name
	mxGetString(prhs[0], command, sizeof(command));
	edfid = edf_open_file(command, 0, 1, 1, &err);

	if(err)
        mexErrMsgTxt("Error opening file.\n");

	list<FSAMPLE> sdata;
	list<FEVENT> edata;
	list<FEVENT> mdata;
	list<string> messages;

	while((edfdattype=edf_get_next_data(edfid))!=NO_PENDING_ITEMS) {
		// Sample data
		if(edfdattype==SAMPLE_TYPE) {
			alldat = edf_get_float_data(edfid);
			sdata.push_back(alldat->fs);
		}
		// Event data
		else if(edfdattype==ENDBLINK||edfdattype==ENDSACC||edfdattype==ENDFIX) {
			alldat = edf_get_float_data(edfid);
			edata.push_back(alldat->fe);
		}
		else if(edfdattype==MESSAGEEVENT) {
			alldat = edf_get_float_data(edfid);
			mdata.push_back(alldat->fe);
			messages.push_back(&(alldat->fe.message->c));
		}
	}

	plhs[0] = mxCreateDoubleMatrix(8, sdata.size(), mxREAL);

    x=mxGetPr(plhs[0]);
    
    list <FSAMPLE>::iterator sitor;

    for(sitor=sdata.begin(); sitor!=sdata.end(); ++sitor) {
        eye=((*sitor).flags & SAMPLE_RIGHT) != 0;
        *x=(*sitor).time;
        ++x;
        *x=(*sitor).gx[eye];
		++x;
        *x=(*sitor).gy[eye];
        ++x;
        *x=(*sitor).pa[eye];
        ++x;
        *x=(*sitor).rx;
		++x;
        *x=(*sitor).ry;
        ++x;
        *x=(*sitor).buttons;
        ++x;
        *x=(*sitor).input;
        ++x;
    }

	plhs[1] = mxCreateDoubleMatrix(3, edata.size(), mxREAL);

    x=mxGetPr(plhs[1]);
    
    list <FEVENT>::iterator eitor;

    for(eitor=edata.begin(); eitor!=edata.end(); ++eitor) {
        *x=(*eitor).sttime;
        ++x;
		*x=(*eitor).entime;
        ++x;
        *x=(*eitor).type;
        ++x;
    }

	plhs[2] = mxCreateDoubleMatrix(1, mdata.size(), mxREAL);

    x=mxGetPr(plhs[2]);
    
    list <FEVENT>::iterator mitor;

    for(mitor=mdata.begin(); mitor!=mdata.end(); ++mitor) {
        *x=(*mitor).sttime;
        ++x;
    }

	char **str;

	str=new char*[messages.size()];

    list <string>::iterator mesitor;

	int i;
    for(mesitor=messages.begin(), i=0; mesitor!=messages.end(); ++mesitor, ++i) {
		str[i]=(char *)(*mesitor).c_str();
    }

	plhs[3] = mxCreateCharMatrixFromStrings(messages.size(), (const char **)str);

	delete[] str;

	preambleTextLength = edf_get_preamble_text_length(edfid);
	if(preambleTextLength > 0) {
		preambleText = new char[preambleTextLength+1];
			
		edf_get_preamble_text(edfid, preambleText, preambleTextLength+1);
		plhs[4]=mxCreateString((const char *)preambleText);

		delete[] preambleText;
	}
	else {
		plhs[4]=mxCreateString("");
	}

	edf_close_file(edfid);
}