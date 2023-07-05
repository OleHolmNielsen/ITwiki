=============================================================================
Migration of a Restructured Text and Sphinx based Wiki to ReadTheDocs
=============================================================================

If you have a ``Restructured Text`` (RST_) and Sphinx_ based Wiki you can migrate it to ReadTheDocs_ 
For MoinMoin based Wikis see also the :ref:`Moin2Sphinx` page.

.. _Sphinx: https://www.sphinx-doc.org/en/master/
.. _RST: https://docutils.sourceforge.io/rst.html
.. _ReadTheDocs: https://readthedocs.org/

Prerequisites
---------------

We assume that you already have your Wiki documentation files in a Git_ repository,
and that these files are RST_ files set up to be formatted with Sphinx_.
For an example see the :ref:`Moin2Sphinx` page.

You should have or create a Sphinx_ Configuration_ file ``conf.py`` in the same folder as the RST_ files.

ReadTheDocs_ assumes that your documentation files all reside in your Git_ project sub-folder named ``docs``.
You can move your files into a ``docs`` folder with this command::

  mkdir docs
  git mv files*.rst docs
  git commit
  git push

.. _Git: https://en.wikipedia.org/wiki/Git
.. _Configuration: https://www.sphinx-doc.org/en/master/usage/configuration.html

Login to ReadTheDocs
--------------------------

Go to the ReadTheDocs_ page and login or sign up.

**WARNING:** Do **not** login with your GitHub_, GitLab_ or Bitbucket_ login!
If you do so, ReadTheDocs_ will take full access to your Git_ repository!
In stead, create your own personal login account.

.. _GitHub: https://github.com/
.. _GitLab: https://about.gitlab.com/
.. _Bitbucket: https://bitbucket.org/product/guides/getting-started/overview#bitbucket-software-hosting-options
