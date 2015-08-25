=================
Basic statistics
=================

.. topic:: **Prerequisites**

   This course assumes that you already know Python. The `scipy-lectures
   <http://scipy-lectures.github.io>`_ give an introduction to Python.

.. tip::

    This page gives an introduction to statistics with Python. It is
    useful to get acquainted with data representations in Python. 

.. contents:: Contents
   :local:
   :depth: 1

|

Data representation and interaction
====================================

.. tip::

    In this document, the Python prompts are represented with the sign
    ">>>". If you need to copy-paste code, you can click on the top right
    of the code blocks, to hide the prompts and the outputs.

Data representation and vocabulary
----------------------------------

The setting that we consider for statistical analysis is that of multiple
*observations* or *samples* described by a set of different *attributes*
or *features*. The data can than be seen as a 2D table, or matrix, with
columns given the different attributes of the data, and rows the
observations. For instance, the data contained in
:download:`examples/brain_size.csv`:

.. include:: examples/brain_size.csv
   :literal:
   :end-line: 6


The panda data-frame
------------------------

.. tip::

    We will store and manipulate this data in a
    :class:`pandas.DataFrame`, from the `pandas
    <http://pandas.pydata.org>`_ module. It is the Python equivalent of
    the spreadsheet table. It is different from a 2D numpy array as it
    has named columns, can contained a mixture of different data types by
    column, and has elaborate selection and pivotal mechanisms.

Reading data from a CSV file
.............................

.. sidebar:: **Separator**

   It is a CSV file, but the separator is ";"

Using the above CSV file that gives observations of brain size and weight
and IQ (Willerman et al. 1991), the data are a mixture of numerical and
categorical values::

    >>> import pandas
    >>> data = pandas.read_csv('examples/brain_size.csv', sep=';', na_values=".")
    >>> data  # doctest: +ELLIPSIS
        Unnamed: 0  Gender  FSIQ  VIQ  PIQ  Weight  Height  MRI_Count
    0            1  Female   133  132  124     118    64.5     816932
    1            2    Male   140  150  124     NaN    72.5    1001121
    2            3    Male   139  123  150     143    73.3    1038437
    3            4    Male   133  129  128     172    68.8     965353
    4            5  Female   137  132  134     147    65.0     951545
    ...

.. warning:: **Missing values**

   The weight of the second individual is missing in the CSV file. If we
   don't specify the missing value (NA = not available) marker, we will
   not be able to do statistical analysis.

Manipulating data
..................

`data` is a pandas dataframe, that resembles R's dataframe::

    >>> data.shape    # 40 rows and 8 columns
    (40, 8)

    >>> data.columns  # It has columns   # doctest: +ELLIPSIS +NORMALIZE_WHITESPACE 
    Index([u'Unnamed: 0', u'Gender', u'FSIQ', u'VIQ', u'PIQ', u'Weight', u'Height', u'MRI_Count'], dtype='object')

    >>> print data['Gender']  # Columns can be addressed by name   # doctest: +ELLIPSIS
    0     Female
    1       Male
    2       Male
    3       Male
    4     Female
    ...

    >>> # Simpler selector
    >>> data[data['Gender'] == 'Female']['VIQ'].mean()
    109.45


**groupby**: splitting a dataframe on values of categorical variables::

    >>> groupby_gender = data.groupby('Gender')
    >>> for gender, value in groupby_gender['VIQ']:
    ...     print gender, value.mean()
    Female 109.45
    Male 115.25


`groupby_gender` is a powerfull object that exposes many
operations on the resulting group of dataframes::

    >>> groupby_gender.mean()
            Unnamed: 0   FSIQ     VIQ     PIQ      Weight     Height  MRI_Count
    Gender                                                                     
    Female       19.65  111.9  109.45  110.45  137.200000  65.765000   862654.6
    Male         21.35  115.0  115.25  111.60  166.444444  71.431579   954855.4

(use tab-completion on `groupby_gender` to find more).

|

.. image:: auto_examples/images/plot_pandas_1.png
   :target: auto_examples/plot_pandas.html
   :align: right
   :scale: 40


.. topic:: **Exercise**
    :class: green

    * What is the mean value for VIQ for the full population?
    * How many males/females were included in this study?

      **Hint** use 'tab completion' to find out the methods that can be
      called, instead of 'mean' in the above example.

    * What is the average value of MRI counts expressed in log units, for
      males and females?

Plotting data
..............

Pandas comes with some plotting tools (that use matplotlib behind the
scene) to display statistics on dataframes::

    >>> from pandas.tools import plotting
    >>> plotting.scatter_matrix(data[['Weight', 'Height', 'MRI_Count']])   # doctest: +SKIP

.. image:: auto_examples/images/plot_pandas_2.png
   :target: auto_examples/plot_pandas.html
   :scale: 50
   :align: center

::

    >>> plotting.scatter_matrix(data[['PIQ', 'VIQ', 'FSIQ']])   # doctest: +SKIP

.. sidebar:: **Two populations**

   The IQ metrics are bimodal. It looks like there are 2 sub-populations.
   We will come back to this hypothesis.

.. image:: auto_examples/images/plot_pandas_3.png
   :target: auto_examples/plot_pandas.html
   :scale: 50
   :align: center

.. topic:: **Exercise**
    :class: green

    Plot the scatter matrix for males only, and for females only. Do you
    think that the 2 sub-populations correspond to gender?

|

Hypothesis testing: two-group comparisons
==========================================

For simple statistical tests, we will use the `stats` sub-module of 
`scipy <http://docs.scipy.org/doc/>`_::

    >>> from scipy import stats

.. seealso::

   Scipy is a vast library. For a tutorial covering the whole scope of
   scipy, see http://scipy-lectures.github.io/


Student's t-test
-----------------

1-sample t-test
...............

:func:`scipy.stats.ttest_1samp` tests if observations are drawn from a
Gaussian distributions of given population mean. It returns the T
statistic, and the p-value (see the function's help)::

    >>> stats.ttest_1samp(data['VIQ'], 0)   # doctest: +ELLIPSIS
    (array(30.088099970...), 1.32891964...e-28)

.. tip::
   
    With a p-value of 10^-28 we can claim that the population mean for
    the IQ (VIQ measure) is not 0.

.. image:: images/two_sided.png
   :scale: 50
   :align: right

.. topic:: **Exercise**
    :class: green

    Is the test performed above one-sided or two-sided? Which one should
    we use, and what is the corresponding p-value?

2-sample t-test
................

We have seen above that the mean VIQ in the male and female populations
were different. To test if this is significant, we do a 2-sample t-test
with :func:`scipy.stats.ttest_ind`::

    >>> female_viq = data[data['Gender'] == 'Female']['VIQ']
    >>> male_viq = data[data['Gender'] == 'Male']['VIQ']
    >>> stats.ttest_ind(female_viq, male_viq)   # doctest: +ELLIPSIS
    (array(-0.77261617232...), 0.4445287677858...)

Paired tests
------------

.. image:: auto_examples/images/plot_pandas_4.png
   :target: auto_examples/plot_pandas.html
   :scale: 70
   :align: right

PIQ, VIQ, and FSIQ give 3 measures of IQ. Let us test if FISQ and PIQ are
significantly different. We need to use a 2 sample test::

    >>> stats.ttest_ind(data['FSIQ'], data['PIQ'])   # doctest: +ELLIPSIS
    (array(0.46563759638...), 0.64277250...)

The problem with this approach is that is forgets that there are links
between observations: FSIQ and PIQ are measure on the same individuals.
Thus the variance due to inter-subject variability is confounding, and
can be removed, using a "paired test", or "repeated measure test"::

    >>> stats.ttest_rel(data['FSIQ'], data['PIQ'])   # doctest: +ELLIPSIS
    (array(1.784201940...), 0.082172638183...)

.. image:: auto_examples/images/plot_pandas_5.png
   :target: auto_examples/plot_pandas.html
   :scale: 60
   :align: right

This is equivalent to a 1-sample test on the difference::

    >>> stats.ttest_1samp(data['FSIQ'] - data['PIQ'], 0)   # doctest: +ELLIPSIS
    (array(1.784201940...), 0.082172638...)

|

T-tests assume Gaussian errors. We
can use a `Wilcoxon signed-rank test
<http://en.wikipedia.org/wiki/Wilcoxon_signed-rank_test>`_, that relaxes
this assumption::

    >>> stats.wilcoxon(data['FSIQ'], data['PIQ'])   # doctest: +ELLIPSIS
    (274.5, 0.106594927...)

.. note::

   The corresponding test in the non paired case is the `Mann–Whitney U
   test <http://en.wikipedia.org/wiki/Mann%E2%80%93Whitney_U>`_,
   :func:`scipy.stats.mannwhitneyu`.

.. topic:: **Exercice**
   :class: green

   * Test the difference between weights in males and females.

   * Use non parametric statistics to test the difference between VIQ in
     males and females.

|

Linear models, ANOVA
======================

A simple linear regression
---------------------------

.. image:: auto_examples/images/plot_regression_1.png
   :target: auto_examples/plot_regression.html
   :scale: 60
   :align: right

Given two set of observations, `x` and `y`, we want to test the
hypothesis that `y` is a linear function of `x`. In other terms:

    :math:`y = x * coef + intercept + e`

where `e` is observation noise. We will use the `statmodels
<http://statsmodels.sourceforge.net/>`_ module to:

#. Fit a linear model. We will use the simplest strategy, `ordinary least
   squares <http://en.wikipedia.org/wiki/Ordinary_least_squares>`_ (OLS).

#. Test that `coef` is non zero.

|

First, we generate simulated data according to the model::

    >>> import numpy as np
    >>> x = np.linspace(-5, 5, 20)
    >>> np.random.seed(1)
    >>> # normal distributed noise
    >>> y = -5 + 3*x + 4 * np.random.normal(size=x.shape)
    >>> # Create a data frame containing all the relevant variables
    >>> data = pandas.DataFrame({'x': x, 'y': y})

Specify an OLS model and fit it::

    >>> # The following will work only with a recent version of statsmodels
    >>> from statsmodels.formula.api import ols
    >>> model = ols("y ~ x", data).fit()
    >>> print(model.summary())  # doctest: +ELLIPSIS +NORMALIZE_WHITESPACE 
                                OLS Regression Results                            
    ==============================================================================
    Dep. Variable:                      y   R-squared:                       0.804
    Model:                            OLS   Adj. R-squared:                  0.794
    Method:                 Least Squares   F-statistic:                     74.03
    Date:                ...                Prob (F-statistic):           8.56e-08
    Time:                        ...        Log-Likelihood:                -57.988
    No. Observations:                  20   AIC:                             120.0
    Df Residuals:                      18   BIC:                             122.0
    Df Model:                           1                                         
    ==============================================================================
                     coef    std err          t      P>|t|      [95.0% Conf. Int.]
    ------------------------------------------------------------------------------
    Intercept     -5.5335      1.036     -5.342      0.000        -7.710    -3.357
    x              2.9369      0.341      8.604      0.000         2.220     3.654
    ==============================================================================
    Omnibus:                        0.100   Durbin-Watson:                   2.956
    Prob(Omnibus):                  0.951   Jarque-Bera (JB):                0.322
    Skew:                          -0.058   Prob(JB):                        0.851
    Kurtosis:                       2.390   Cond. No.                         3.03
    ==============================================================================

.. topic:: **Exercise**
   :class: green

   Retrieve the estimated parameters from the model above. **Hint**:
   use tab-completion to find the relevent attribute.


Multiple Regression
--------------------

.. image:: auto_examples/images/plot_regression_3d_1.png
   :target: auto_examples/plot_regression_3d.html
   :scale: 45
   :align: right

|

Consider a linear model explaining a variable `z` (the dependent
variable) with 2 variables `x` and `y`:

    :math:`z = x \, c_1 + y \, c_2 + i + e`

Such a model can be seen in 3D as fitting a plane to a cloud of (`x`,
`y`, `z`) points.

|
|

**Example: the iris data**


.. image:: auto_examples/images/plot_iris_analysis_1.png
   :target: auto_examples/plot_iris_analysis_1.html
   :scale: 80
   :align: center

::

    >>> data = pandas.read_csv('examples/iris.csv')
    >>> model = ols('sepal_width ~ name + petal_length', data).fit()
    >>> print(model.summary())  # doctest: +ELLIPSIS +NORMALIZE_WHITESPACE 
                                OLS Regression Results                            
    ==============================================================================
    Dep. Variable:            sepal_width   R-squared:                       0.478
    Model:                            OLS   Adj. R-squared:                  0.468
    Method:                 Least Squares   F-statistic:                     44.63
    Date:                ...                Prob (F-statistic):           1.58e-20
    Time:                        ...        Log-Likelihood:                -38.185
    No. Observations:                 150   AIC:                             84.37
    Df Residuals:                     146   BIC:                             96.41
    Df Model:                           3                                       
    ===============================================================================...
                             coef    std err          t     P>|t|  [95.0% Conf. Int.]
    -------------------------------------------------------------------------------...
    Intercept              2.9813      0.099     29.989     0.000      2.785     3.178
    name[T.versicolor]    -1.4821      0.181     -8.190     0.000     -1.840    -1.124
    name[T.virginica]     -1.6635      0.256     -6.502     0.000     -2.169    -1.158
    petal_length           0.2983      0.061      4.920     0.000      0.178     0.418
    ==============================================================================
    Omnibus:                        2.868   Durbin-Watson:                   1.753
    Prob(Omnibus):                  0.238   Jarque-Bera (JB):                2.885
    Skew:                          -0.082   Prob(JB):                        0.236
    Kurtosis:                       3.659   Cond. No.                         54.0
    ==============================================================================

Post-hoc ANOVA: contrast vectors
---------------------------------

In the above iris example, we wish to test if the petal length is
different between versicolor and virginica, after removing the effect of
sepal width. This can be formulated as testing the difference between the
coefficient associated to versicolor and virginica in the linear model
estimated above (it is an Analysis of Variance, ANOVA). For this, we
write a vector of 'contrast' on the parameters estimated: we want to test
"name[T.versicolor] - name[T.virginica]", with an 'F-test'::

    >>> print(model.f_test([0, 1, -1, 0]))
    <F test: F=array([[ 3.24533535]]), p=[[ 0.07369059]], df_denom=146, df_num=1>

Is this difference significant?

|

.. topic:: **Exercice**
   :class: green

   Going back to the brain size + IQ data, test if the VIQ of male and
   female are different after removing the effect of brain size, height
   and weight.

