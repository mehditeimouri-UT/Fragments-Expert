/* This program looks for the nearest neighbors of all data points in m dimensions and iterates
 * these neighbors one step (more precisely delay steps) into the future. If the ratio of the
 * distance of the iteration and that of the nearest neighbor exceeds a given threshold the point
 * is marked as a wrong neighbor. The output is the fraction of false neighbors for the specified
 * embedding dimensions (see [1]).
 *
 * [1] M. B. Kennel, R. Brown, and H. D. I. Abarbanel, Determining embedding dimension for phase-space
 * reconstruction using a geometrical construction, Phys. Rev. A 45, 3403 (1992).
 *
 * Copyright (C) 2005 Rainer Hegger <hegger@theochem.uni-frankfurt.de>
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
 * Usage method: results = false_nearest_FFC(series,minemb,maxemb,rt);
 *
 * Input:
 * series: A fragment of bytes
 * minemb: Minimum embedding dimension of the vectors
 * maxemb: Maximum embedding dimension of the vectors
 * rt: ratio factor
 *
 * Outputs:
 * results: A matrix with four columns
 *  1st column: The dimension
 *  2nd column: The fraction of false nearest neighbors
 *  3rd column: The average size of the neighborhood
 *  4th column: The square root of the average of the squared size of the neighborhood
 *
 * Revisions:
 * 2005-Dec-16   The first version was written by Rainer Hegger.
 * 2020-Mar-17   The function was written in c-mex format. Moreover, single-variate inputs (one-dimensional fragments) are considered.
 */

#include "mex.h"
#include <math.h>

double **series;
double **results;
int results_num;
unsigned long length,theiler;
unsigned int maxdim;
unsigned int delay,comp,maxemb,minemb;
double rt;
double eps0;
double aveps,vareps;
double varianz;

#define BOX 1024
int ibox=BOX-1;
long **box,*list;
unsigned int *vcomp,*vemb;
unsigned long toolarge;

int variance(double *s,unsigned long l,double *av,double *var)
{
    unsigned long i;
    double h;

    *av= *var=0.0;

    for (i=0;i<l;i++) {
        h=s[i];
        *av += h;
        *var += h*h;
    }
    *av /= (double)l;
    *var=sqrt(fabs((*var)/(double)l-(*av)*(*av)));
    if (*var == 0.0)
        return(1); // Variance of the data is zero. Exiting!
    return(0);
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
        return(2); //Data range is zero. It makes no sense to continue. Exiting!
    return(0);
}

void mmb(unsigned int hdim,unsigned int hemb,double eps)
{
    unsigned long i;
    long x,y;

    for (x=0;x<BOX;x++)
        for (y=0;y<BOX;y++)
            box[x][y] = -1;

    for (i=0;i<length-(maxemb+1)*delay;i++) {
        x=(long)(series[0][i]/eps)&ibox;
        y=(long)(series[hdim][i+hemb]/eps)&ibox;
        list[i]=box[x][y];
        box[x][y]=i;
    }
}

char find_nearest(long n,unsigned int dim,double eps)
{
    long x,y,x1,x2,y1,i,i1,ic,ie;
    long element,which= -1;
    double dx,maxdx,mindx=1.1,hfactor,factor;

    ic=vcomp[dim];
    ie=vemb[dim];
    x=(long)(series[0][n]/eps)&ibox;
    y=(long)(series[ic][n+ie]/eps)&ibox;

    for (x1=x-1;x1<=x+1;x1++)
    {
        x2=x1&ibox;
        for (y1=y-1;y1<=y+1;y1++)
        {
            element=box[x2][y1&ibox];
            while (element != -1)
            {
                if (labs(element-n) > theiler)
                {
                    maxdx=fabs(series[0][n]-series[0][element]);
                    for (i=1;i<=dim;i++)
                    {
                        ic=vcomp[i];
                        i1=vemb[i];
                        dx=fabs(series[ic][n+i1]-series[ic][element+i1]);
                        if (dx > maxdx)
                            maxdx=dx;
                    }
                    if ((maxdx < mindx) && (maxdx > 0.0))
                    {
                        which=element;
                        mindx=maxdx;
                    }
                }
                element=list[element];
            }
        }
    }

    if ((which != -1) && (mindx <= eps) && (mindx <= varianz/rt))
    {
        aveps += mindx;
        vareps += mindx*mindx;
        factor=0.0;
        for (i=1;i<=comp;i++)
        {
            ic=vcomp[dim+i];
            ie=vemb[dim+i];
            hfactor=fabs(series[ic][n+ie]-series[ic][which+ie])/mindx;
            if (hfactor > factor)
                factor=hfactor;
        }
        if (factor > rt)
            toolarge++;
        return(1);
    }
    return(0);
}

int false_nearest()
{
    double min,inter=0.0,ind_inter,epsilon,av,ind_var;
    char *nearest,alldone;
    long i;
    unsigned int dim,emb;
    unsigned long donesofar;
    int ret_val;

    for (i=0;i<comp;i++)
    {
        ret_val = rescale_data(series[i],length,&min,&ind_inter);
        if (ret_val!=0) return(ret_val);

        ret_val = variance(series[i],length,&av,&ind_var);
        if (ret_val!=0) return(ret_val);

        if (i == 0)
        {
            varianz=ind_var;
            inter=ind_inter;
        }
        else
        {
            varianz=(varianz>ind_var)?ind_var:varianz;
            inter=(inter<ind_inter)?ind_inter:inter;
        }
    }

    list=(long*)malloc(sizeof(long)*length);
    nearest=(char*)malloc(length);
    box=(long**)malloc(sizeof(long*)*BOX);
    for (i=0;i<BOX;i++)
        box[i]=(long*)malloc(sizeof(long)*BOX);
    vcomp=(unsigned int*)malloc(sizeof(int)*(maxdim));
    vemb=(unsigned int*)malloc(sizeof(int)*(maxdim));

    for (i=0;i<maxdim;i++)
    {
        if (comp == 1)
        {
            vcomp[i]=0;
            vemb[i]=i;
        }
        else
        {
            vcomp[i]=i%comp;
            vemb[i]=(i/comp)*delay;
        }
    }

    for (emb=minemb;emb<=maxemb;emb++)
    {
        dim=emb*comp-1;
        epsilon=eps0;
        toolarge=0;
        alldone=0;
        donesofar=0;
        aveps=0.0;
        vareps=0.0;
        for (i=0;i<length;i++)
            nearest[i]=0;

        while (!alldone && (epsilon < 2.0*varianz/rt))
        {
            alldone=1;
            mmb(vcomp[dim],vemb[dim],epsilon);
            for (i=0;i<length-maxemb*delay;i++)
                if (!nearest[i])
                {
                    nearest[i]=find_nearest(i,dim,epsilon);
                    alldone &= nearest[i];
                    donesofar += (unsigned long)nearest[i];
                }

            epsilon*=sqrt(2.0);
            if (!donesofar)
                eps0=epsilon;
        }

        if (donesofar == 0)
            return(3); // Not enough points found! Exit!

        aveps *= (1.0/(double)donesofar);
        vareps *= (1.0/(double)donesofar);

        results[results_num][0] = dim+1;
        results[results_num][1] = (double)toolarge/(double)donesofar;
        results[results_num][2] = aveps*inter;
        results[results_num][3] = sqrt(vareps)*inter;
        results_num++;
    }

    free(nearest);
    return(0);
}


void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
    unsigned long dim1,dim2,i,j;
    double *out,*series_tmp;
    int retval;

    /* Check for the proper number of arguments. */
    if (nrhs != 4)
        mexErrMsgTxt("Four inputs are required.");
    if (nlhs > 1)
        mexErrMsgTxt("No more than one output is required!");

    /* Initialization */
    theiler=0;
    delay=1;
    comp=1;
    eps0=1.0e-5;
    results_num=0;

    /* Get the length of the first input vector. */
    dim1 = mxGetM(prhs[0]);
    dim2 = mxGetN(prhs[0]);
    if (dim1>1 && dim2>1)
        mexErrMsgTxt("Input must be vector.\n");
    length = dim1*dim2;

    /* Get pointers to the inputs and prepare inputs. */
    series_tmp = mxGetPr(prhs[0]);
    series = (double**) malloc (sizeof(double*)*1);
    series[0] = (double*)malloc(sizeof(double)*length);
    for(j=0;j<length;j++)
        series[0][j] = series_tmp[j];

    /* Read other inputs */
    minemb = (unsigned int) mxGetScalar(prhs[1]); //Minimum embedding dimension of the vectors
    maxemb = (unsigned int) mxGetScalar(prhs[2]); //Maximum embedding dimension of the vectors
    rt = mxGetScalar(prhs[3]); //ratio factor
    if ((rt<=0) || minemb==0 || maxemb==0 || maxemb<minemb || maxemb>50 || minemb>50)
        mexErrMsgTxt("Wrong input parameters!\n");
    maxdim = comp*(maxemb+1);

    /* Prepare Output */
    results = (double**) malloc (sizeof(double*)*(maxemb-minemb+1));
    for(j=0;j<=(maxemb-minemb);j++)
        results[j] = (double*)malloc(sizeof(double)*4);

    /* Call the C subroutine. */
    if (((int)length-(int)(maxemb+1)*(int)delay)<0)
        retval = 4; // Data length is too small. Exiting!
    else
        retval = false_nearest();

    /* Create a new array and set the output pointer to it. */
    plhs[0] = mxCreateDoubleMatrix(results_num, 4, mxREAL);
    out =  mxGetPr(plhs[0]);
    for(i=0;i<results_num;i++)
        for(j=0;j<4;j++)
            out[i+j*results_num] = results[i][j];

    /* Free Memory */
    free(series[0]);
    free(series);
    for(j=0;j<=(maxemb-minemb);j++)
        free(results[j]);
    free(results);
    if ((retval==0) || (retval==3))
    {
        free(list);
        for (j=0;j<BOX;j++)
            free(box[j]);
        free(box);
        free(vcomp);
        free(vemb);
    }

    return;
}