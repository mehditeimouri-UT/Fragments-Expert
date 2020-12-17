/* This function calculates the longest common subsequence (LCSSeq) between two
 * vectors using a dynamic programming approach.
 *
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
 * Usage method: L = LCSSeq_FFC(X,Y);
 *
 * Inputs:
 *  X: The first vector
 *  Y: The second vector
 *
 * Output:
 *  L: The length of the longest common subsequence between X and Y
 *
 * Revisions:
 * 2020-Apr-26   function was created
 */

#include "mex.h"

int *X;
int *Y;
int **Z;

int LCSSeq(int m,int n)
{
    int i,j;

    for (i=0;i<=m;i++)
    {
        for (j=0;j<=n;j++)
        {
            if ((i==0)||(j==0))
                Z[i][j] = 0;

            else
            {
                if (X[i-1]==Y[j-1])
                    Z[i][j] = Z[i-1][j-1]+1;

                else
                {
                    if (Z[i-1][j]>Z[i][j-1])
                        Z[i][j] = Z[i-1][j];
                    else
                        Z[i][j] = Z[i][j-1];
                }
            }
        }
    }

    return(Z[m][n]);

}
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
    int m,n,dim1,dim2,j;
    double *Xd,*Yd,*out;
    int L;

    /* Check for the proper number of arguments. */
    if (nrhs != 2)
        mexErrMsgTxt("Two inputs are required.");
    if (nlhs > 1)
        mexErrMsgTxt("No more than one output is required!");

    /* Get the length of the first input vector. */
    dim1 = mxGetM(prhs[0]);
    dim2 = mxGetN(prhs[0]);
    if (dim1>1 && dim2>1)
        mexErrMsgTxt("First Input must be vector.\n");
    m = dim1*dim2;

    /* Get the length of the second input vector. */
    dim1 = mxGetM(prhs[1]);
    dim2 = mxGetN(prhs[1]);
    if (dim1>1 && dim2>1)
        mexErrMsgTxt("Second Input must be vector.\n");
    n = dim1*dim2;

    /* Get pointers to the inputs and prepare inputs. */
    Xd = mxGetPr(prhs[0]);
    X = (int*)malloc(sizeof(int)*m);
    for(j=0;j<m;j++)
        X[j] = (int) Xd[j];

    Yd = mxGetPr(prhs[1]);
    Y = (int*)malloc(sizeof(int)*n);
    for(j=0;j<n;j++)
        Y[j] = (int) Yd[j];

    /* Initialize Z */
    Z = (int**)malloc(sizeof(int*)*(m+1));
    for(j=0;j<=m;j++)
        Z[j] = (int*)malloc(sizeof(int)*(n+1));

    /* Call the C subroutine. */
    L = LCSSeq(m,n);

    /* Create a new array and set the output pointer to it. */
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    out =  mxGetPr(plhs[0]);
    out[0] = (double) L;

    /* Free Memory */
    free(Y);
    free(X);
    for(j=0;j<=m;j++)
        free(Z[j]);
    free(Z);

    return;

}