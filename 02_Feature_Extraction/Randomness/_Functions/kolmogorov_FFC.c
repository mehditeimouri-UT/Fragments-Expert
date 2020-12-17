/* This c-mex function estimates the algorithmic complexity of S using the method proposed in [1].
 * [1] Kaspar, F., and H. G. Schuster. "Easily calculable measure for the complexity of spatiotemporal patterns."
 * Physical Review A 36.2 (1987): 842.
 *
 * Copyright (C) 2005 Stephen Faul <stephenf@rennes.ucc.ie>
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
 * Usage method: c = kolmogorov_FFC(S);
 *
 * Input:
 * S: A fragment of bytes
 *
 * Outputs:
 * c: Normalized algorithmic complexity of S
 *
 * Revisions:
 * 2005-Feb-09   The first version was written by Stephen Faul.
 * 2020-Mar-17   In order to increase the speed, the function was written in c-mex format.
 *               In order to normalize complexity, it is divided by fragment length.
 *               For file fragment classification, it seems to be a better
 *               normalization.
 */

#include "mex.h"

int ArCmp_FFC(int *S,size_t n)
{
    int c;
    size_t l,i,k,kmax;

    // Initializarion
    c = 1;
    l = 1;
    i = 0;
    k = 1;
    kmax = 1;

    // Algorithm Loop
    while ((l+k)<=n)
    {
        if (S[i+k-1]==S[l+k-1])
        {
            k = k+1;
            if ((l+k)<n)
                continue;
            else
            {
                c = c+1;
                break;
            }
        }
        else
        {
            if (k>kmax)
                kmax = k;
            i = i+1;
            if (i==l)
            {
                c = c+1;
                l = l+kmax;
                if (l>=n)
                    break;
                else
                {
                    i = 0;
                    k = 1;
                    kmax = 1;
                    continue;
                }
            }
            else
            {
                k = 1;
                continue;
            }
        }
    }

    return c;
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
    c_int = ArCmp_FFC(S_int,n);

    /* Create a new array and set the output pointer to it. */
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    c =  mxGetPr(plhs[0]);
    c[0] = (double) c_int / (double) n; // Normalization

    //free memory
    free(S_int);

    return;
}
