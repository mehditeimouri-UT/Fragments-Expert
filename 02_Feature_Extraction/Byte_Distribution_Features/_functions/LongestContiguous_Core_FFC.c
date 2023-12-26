/* This c-mex function This function returns size of the longest contiguous streak of repeating
 * bytes in input fragment
 *
 * Copyright (C) 2023 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir>
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
 * Usage method: L = LongestContiguous_Core_FFC(fragment);
 *
 * Input:
 * fragment: A fragment of bytes
 *
 * Outputs:
 * L: size of the longest contiguous streak of repeating bytes 
 *
 * Revisions:
 * 2023-Dec-25   The was written 
 */

#include "mex.h"

int LongestContiguous_Core_FFC(int *fragments,int length)
{
    int i, newval, L = 1;
    int Lmax = 1;
    int val = fragments[0];
    
    for (i = 1; i < length; i++) {
        newval = fragments[i];
        if (newval == val) {
            L = L + 1;
        } else {
            if (L > Lmax) {
                Lmax = L;
            }
            L = 1;
        }
        val = newval;
    }
    
    if (L > Lmax) {
        Lmax = L;
    }
    
    return Lmax;
}

void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
    double *S,*c;
    int *S_int,c_int;
    size_t dim1,dim2,n;
    int j;

    /* Check for the proper number of arguments. */
    if (nrhs != 1)
        mexErrMsgTxt("One input is required.");
    if (nlhs > 1)
        mexErrMsgTxt("No more than one output is required!");

    /* Check that first input is real*/
    if (!mxIsDouble(prhs[0]))
        mexErrMsgTxt("Input must be real.\n");

    /* Get the length of the input vector. */
    dim1 = mxGetM(prhs[0]);
    dim2 = mxGetN(prhs[0]);
    if (dim1>1 && dim2>1)
        mexErrMsgTxt("Input must be vector.\n");
    n = dim1*dim2;

    /* Get pointers to the inputs. */
    S =  mxGetPr(prhs[0]);

    /* Convert input to integer values */
    S_int = (int*) malloc (dim1*dim2*sizeof(int));
    for(j=0;j<n;j++)
        S_int[j] = (int) S[j];

    /* Call the C subroutine. */
    c_int = LongestContiguous_Core_FFC(S_int,n);

    /* Create a new array and set the output pointer to it. */
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    c =  mxGetPr(plhs[0]);
    c[0] = (double) c_int; // Normalization

    //free memory
    free(S_int);

    return;
}
