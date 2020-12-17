/* This program estimates the Lyapunov exponents of a given time series using the algorithm of Kantz [1].
 *
 * [1] H. Kantz, A robust method to estimate the maximal Lyapunov exponent of a time series, Phys. Lett. A 185, 77 (1994).
 *
 * Copyright (C) 1999 Rainer Hegger <hegger@theochem.uni-frankfurt.de>
 * Copyright (C) 2020 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir>
 *
 * This file is a part of Fragments-Expert software, a software package for
 * feature extraction from file fragments and classification among various file formats.
 *
 * Fragments-Expert software is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * Fragments-Expert software is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.
 * If not, see <http://www.gnu.org/licenses/>.
 *
 * Usage method: results = lyap_exp_k_FFC(series,mindim,maxdim);
 *
 * Input:
 * series: A fragment of bytes
 * mindim: Minimum embedding dimension of the vectors
 * maxdim: Maximum embedding dimension of the vectors
 *
 * Outputs:
 * results: A vector with length maxdim-mindim+1 containing Lyapunov exponents
 *
 * Revisions:
 * 1999-Sep-03   The first version was written by Rainer Hegger.
 * 2020-Mar-28   The function was written in c-mex format.
 */

#include "mex.h"
#include <math.h>
#include <limits.h>

//FILE *debugfile;
double *series;
unsigned long length;

#define BOX 128
const unsigned int ibox=BOX-1;

unsigned long exclude;
unsigned long reference;
unsigned int maxdim;
unsigned int mindim;
unsigned int delay;
unsigned int column;
unsigned int epscount;
unsigned int maxiter;
unsigned int window;
double epsmin,epsmax;
char eps0set,eps1set;

double *series,**lyap,*out;
long box[BOX][BOX],*liste,**lfound,*found,**count;
double max,min;

void iterate_points(long act)
{
    double **lfactor;
    double *dx,tmp;
    unsigned int i,j,l,l1;
    long k,element,**lcount;

    lfactor=(double**)malloc(sizeof(double*)*(maxdim-1));
    lcount=(long**)malloc(sizeof(long*)*(maxdim-1));
    for (i=0;i<maxdim-1;i++)
    {
        lfactor[i]=(double*)malloc(sizeof(double)*(maxiter+1));
        lcount[i]=(long*)malloc(sizeof(long)*(maxiter+1));
    }
    dx=(double*)malloc(sizeof(double)*(maxiter+1));

    for (i=0;i<=maxiter;i++)
        for (j=0;j<maxdim-1;j++)
        {
            lfactor[j][i]=0.0;
            lcount[j][i]=0;
        }

    for (j=mindim-2;j<maxdim-1;j++)
    {
        for (k=0;k<found[j];k++)
        {
            element=lfound[j][k];
            for (i=0;i<=maxiter;i++)
            {
                tmp = series[act+i]-series[element+i];
                dx[i]=tmp*tmp;
            }
            for (l=1;l<j+2;l++)
            {
                l1=l*delay;
                for (i=0;i<=maxiter;i++)
                {
                    tmp = series[act+i+l1]-series[element+l1+i];
                    dx[i] += tmp*tmp;
                }
            }
            for (i=0;i<=maxiter;i++)
                if (dx[i] > 0.0){
                    lcount[j][i]++;
                    lfactor[j][i] += dx[i];
                }
        }
    }
    for (i=mindim-2;i<maxdim-1;i++)
        for (j=0;j<=maxiter;j++)
            if (lcount[i][j])
            {
                count[i][j]++;
                lyap[i][j] += log(lfactor[i][j]/lcount[i][j])/2.0;
            }

    for (i=0;i<maxdim-1;i++)
    {
        free(lfactor[i]);
        free(lcount[i]);
    }
    free(lcount);
    free(lfactor);
    free(dx);
}

void lfind_neighbors(long act,double eps)
{
    unsigned int hi,k,k1;
    long i,j,i1,i2,j1,element;
    static long lwindow;
    double dx,eps2=eps*eps,tmp;

    lwindow=(long)window;
    for (hi=0;hi<maxdim-1;hi++)
        found[hi]=0;
    i=(long)(series[act]/eps)&ibox;
    j=(long)(series[act+delay]/eps)&ibox;
    for (i1=i-1;i1<=i+1;i1++)
    {
        i2=i1&ibox;
        for (j1=j-1;j1<=j+1;j1++)
        {
            element=box[i2][j1&ibox];
            while (element != -1)
            {
                if ((element < (act-lwindow)) || (element > (act+lwindow)))
                {
                    dx=series[act]-series[element];
                    dx*=dx;
                    if (dx <= eps2) {
                        for (k=1;k<maxdim;k++)
                        {
                            k1=k*delay;
                            tmp = series[act+k1]-series[element+k1];
                            dx += tmp*tmp;
                            if (dx <= eps2)
                            {
                                k1=k-1;
                                lfound[k1][found[k1]]=element;
                                found[k1]++;
                            }
                            else
                                break;
                        }
                    }
                }
                element=liste[element];
            }
        }
    }
}

void put_in_boxes(double eps)
{
  unsigned long i;
  long j,k;
  static unsigned long blength;

  blength=length-(maxdim-1)*delay-maxiter;

  for (i=0;i<BOX;i++)
    for (j=0;j<BOX;j++)
      box[i][j]= -1;

  for (i=0;i<blength;i++) {
    j=(long)(series[i]/eps)&ibox;
    k=(long)(series[i+delay]/eps)&ibox;
    liste[i]=box[j][k];
    box[j][k]=i;
  }
}

int rescale_data(double *x,unsigned long l,double *min,double *interval)
{
    int i;

    *min=*interval=x[0];

    for (i=1;i<l;i++)
    {
        if (x[i] < *min) *min=x[i];
        if (x[i] > *interval) *interval=x[i];
    }
    *interval -= *min;

    if (*interval != 0.0)
    {
        for (i=0;i<l;i++)
            x[i]=(x[i]- *min)/ *interval;
    }
    else
        return(1); //Data range is zero. It makes no sense to continue. Exiting!
    return(0);
}

int lyap_exp_k()
{
    double eps_fak,ret_val;
    double epsilon;
    unsigned int i,j,l;
    double x[3],y[3],xmean,ymean,slope;
    unsigned int cnt;

    ret_val = rescale_data(series,length,&min,&max);
    if (ret_val!=0) return(ret_val);

    if (eps0set)
        epsmin /= max;
    if (eps1set)
        epsmax /= max;

    if (epsmin >= epsmax) {
        epsmax=epsmin;
        epscount=1;
    }

    if (reference > (length-maxiter-(maxdim-1)*delay))
        reference=length-maxiter-(maxdim-1)*delay;

    if ((maxiter+(maxdim-1)*delay) >= length)
        return(2); // Too few points to handle these parameters

    liste=(long*)malloc(sizeof(long)*(length));
    found=(long*)malloc(sizeof(long)*(maxdim-1));
    lfound=(long**)malloc(sizeof(long*)*(maxdim-1));
    for (i=0;i<maxdim-1;i++)
        lfound[i]=(long*)malloc(sizeof(long)*(length));
    count=(long**)malloc(sizeof(long*)*(maxdim-1));
    for (i=0;i<maxdim-1;i++)
        count[i]=(long*)malloc(sizeof(long)*(maxiter+1));
    lyap=(double**)malloc(sizeof(double*)*(maxdim-1));
    for (i=0;i<maxdim-1;i++)
        lyap[i]=(double*)malloc(sizeof(double)*(maxiter+1));

    if (epscount == 1)
        eps_fak=1.0;
    else
        eps_fak=pow(epsmax/epsmin,1.0/(double)(epscount-1));

    for (l=0;l<epscount;l++)
    {
        epsilon=epsmin*pow(eps_fak,(double)l);
        for (i=0;i<maxdim-1;i++)
            for (j=0;j<=maxiter;j++)
            {
                count[i][j]=0;
                lyap[i][j]=0.0;
            }
        put_in_boxes(epsilon);
        for (i=0;i<reference;i++)
        {
            lfind_neighbors(i,epsilon);
            iterate_points(i);
        }
        //fprintf(debugfile,"epsilon= %e\n",epsilon*max);
        for (i=mindim-2;i<maxdim-1;i++)
        {
            //fprintf(debugfile,"#epsilon= %e  dim= %d\n",epsilon*max,i+2);
            cnt = 0;
            for (j=0;j<=maxiter;j++)
                if (count[i][j])
                {
                    //fprintf(debugfile,"%d %e %ld\n",j,lyap[i][j]/count[i][j],count[i][j]);

                    x[cnt]=(double)j;
                    y[cnt]=lyap[i][j]/count[i][j];
                    cnt++;
                    if (cnt==3)
                        break;
                }
            //fprintf(debugfile,"\n");

            if (cnt==3)
            {
                xmean = (x[0]+x[1]+x[2])/3.0;
                ymean = (y[0]+y[1]+y[2])/3.0;
                x[0]-=xmean;
                x[1]-=xmean;
                x[2]-=xmean;
                y[0]-=ymean;
                y[1]-=ymean;
                y[2]-=ymean;
                slope=((x[0]*y[0])+(x[1]*y[1])+(x[2]*y[2]))/(x[0]*x[0]+x[1]*x[1]+x[2]*x[2]);
                if (slope>out[i+2-mindim])
                        out[i+2-mindim] = slope;
            }
        }
    }

    return(0);
}


void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
    unsigned long dim1,dim2,i,j;
    double *series_tmp;
    int retval;

    /* Check for the proper number of arguments. */
    if (nrhs != 3)
        mexErrMsgTxt("Three inputs are required.");
    if (nlhs > 1)
        mexErrMsgTxt("No more than one output is required!");

    /* Initialization */
    //debugfile = fopen("debugfile.dat","w");
    exclude=0;
    delay=1;
    column=1;
    epscount=5;
    maxiter=10;
    window=0;
    epsmin=1.e-3;
    epsmax=1.e-2;
    eps0set=0;
    eps1set=0;

    /* Get the length of the first input vector. */
    dim1 = mxGetM(prhs[0]);
    dim2 = mxGetN(prhs[0]);
    if (dim1>1 && dim2>1)
        mexErrMsgTxt("Input must be vector.\n");
    length = dim1*dim2;
    reference = length;

    /* Get pointers to the inputs and prepare inputs. */
    series_tmp = mxGetPr(prhs[0]);
    series = (double*) malloc(sizeof(double)*length);
    for(j=0;j<length;j++)
        series[j] = series_tmp[j];

    /* Read other inputs */
    mindim = (unsigned int) mxGetScalar(prhs[1]); //Minimum embedding dimension of the vectors
    maxdim = (unsigned int) mxGetScalar(prhs[2]); //Maximum embedding dimension of the vectors
    if (maxdim < 2 || maxdim > 50)
        mexErrMsgTxt("Wrong input parameters!\n");
    if (mindim < 2 || mindim > 50)
        mexErrMsgTxt("Wrong input parameters!\n");
    if (mindim > maxdim)
        mexErrMsgTxt("Wrong input parameters!\n");

    /* Prepare Output */
    /* Create a new array and set the output pointer to it. */
    plhs[0] = mxCreateDoubleMatrix(1,maxdim-mindim+1, mxREAL);
    out =  mxGetPr(plhs[0]);
    for(j=0;j<(maxdim-mindim+1);j++)
        out[j] = -1;

    /* Call the C subroutine. */
    retval = lyap_exp_k();

    /* Free Memory */
    //fclose(debugfile);
    free(series);
    if (retval==0)
    {
        free(liste);
        free(found);
        for (i=0;i<maxdim-1;i++)
            free(lfound[i]);
        free(lfound);
        for (i=0;i<maxdim-1;i++)
            free(count[i]);
        free(count);
        for (i=0;i<maxdim-1;i++)
            free(lyap[i]);
        free(lyap);
    }

    return;
}