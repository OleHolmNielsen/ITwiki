=============================================================================
Migration of a Restructured Text and Sphinx based Wiki to ReadTheDocs
=============================================================================

If you have a ``Restructured Text`` (RST_) and Sphinx_ based Wiki you can migrate it to ReadTheDocs_ 
For ``MoinMoin`` based Wikis see also the Moin2Sphinx_ page.

Please read the Example_projects_ page which describes **requirements** for your documentation project.
You may choose the example-sphinx-basic_ setup.

ReadTheDocs_ is a *Continuous Documentation Deployment* platform for your software project.
Every time you change something in your documentation, ReadTheDocs_ will detect your change and build your documentation.

.. _Sphinx: https://www.sphinx-doc.org/en/master/
.. _RST: https://docutils.sourceforge.io/rst.html
.. _ReadTheDocs: https://readthedocs.org/
.. _Moin2Sphinx: https://github.com/OleHolmNielsen/Moin2Sphinx
.. _Example_projects: https://docs.readthedocs.io/en/stable/examples.html
.. _example-sphinx-basic: https://github.com/readthedocs-examples/example-sphinx-basic/

Prerequisites
---------------

We assume that you already have your Wiki documentation files in a Git_ repository,
and that these files are RST_ files set up to be formatted with Sphinx_.
For an example see the Moin2Sphinx_ page.

You should have (or create) a Sphinx_ Configuration_ file ``conf.py`` in the same folder as the RST_ files.

ReadTheDocs_ assumes that your documentation files all reside in your Git_ project sub-folder named ``docs``.
You can move your Sphinx_ files (including ``conf.py``) into a ``docs`` folder with these commands::

  mkdir docs
  git mv conf.py docs/
  git mv <your-files>.rst docs/
  git commit
  git push

For our desired **Manual** import of a Git_ repository to ReadTheDocs_, a ``.readthedocs.yaml`` file 
must be added to your Git_ ``docs`` folder.
Download the readthedocs.yaml_ file from the example-sphinx-basic_ page, for example::

  cd docs/
  wget https://raw.githubusercontent.com/readthedocs-examples/example-sphinx-basic/main/.readthedocs.yaml
  git add .readthedocs.yaml
  git commit .readthedocs.yaml
  git push

This file may be good as-is without any modifications.

.. _Git: https://en.wikipedia.org/wiki/Git
.. _Configuration: https://www.sphinx-doc.org/en/master/usage/configuration.html
.. _readthedocs.yaml: https://github.com/readthedocs-examples/example-sphinx-basic/blob/main/.readthedocs.yaml

Login to ReadTheDocs
--------------------------

Go to the ReadTheDocs_ page and login, or sign up if you are a new user.

**WARNING:** Do **not** login with your GitHub_, GitLab_ or Bitbucket_ login!
If you do so, ReadTheDocs_ will be granted **full access** to your entire Git_ repository!
For security reasons you probably do not want to allow this access!
In stead, create your own personal login account.

.. _GitHub: https://github.com/
.. _GitLab: https://about.gitlab.com/
.. _Bitbucket: https://bitbucket.org/product/guides/getting-started/overview#bitbucket-software-hosting-options

Import a repository
--------------------------

When you have logged in, you can click on ``Import a Project`` (your Git_ project documentation)
from the Dashboard_ page.

Now click the ``Import Manually`` button so that you do not divulge your Git_ login information!

In the *Project Details* page **select carefully a suitable name** for your project.
**Note:** This name will become the DNS domain name of your documentation pages,
for example, the name ``My nice documentation`` will become ``https://my-nice-documentation.readthedocs.io``.

In the ``Repository URL`` field enter the URL of your Git_ project.
It is the same URL which you use to make a ``git clone`` command of your code,
for example::

  https://github.com/OleHolmNielsen/Niflheim_system.git

If you wish to use a Git_ branch other than the default ``main`` branch,
enter the branch name in the ``Default branch`` box.

Click ``Next`` which will take yo to the *Add a project configuration file* page.
Note the instruction::

  Make sure your project has a .readthedocs.yaml configuration file at the root directory of your repository. 

Since we have already created a readthedocs.yaml_ file, we can click the ``Finish`` button.

.. _Dashboard: https://readthedocs.org/dashboard/

Project overview
-------------------

On your project's overview page you can click the ``Build version`` button to generate the web pages.
They will be published, for example, on the page ``https://my-nice-documentation.readthedocs.io``.

When you get (hopefully) the ``Build completed`` message,
click on the ``View docs`` link to go the documentation.

Add Git integration
---------------------

You should integrate ReadTheDocs_ with your Git_ project by defining as Webhook_
where your Git_ project pushes a message to ReadTheDocs_ telling that updates exist.
This causes ReadTheDocs_ to rebuild your documentation from the latest Git_ files.

First create an Integration_ on ReadTheDocs_ in your project page by clicking ``Admin->Integrations``.
Now click on ``Add Integration``.
Select the appropriate ``Integration type``, for example, *GitHub incoming webhook*
and click ``Add Integration``.
Since we have chosen to ``Import Manually``,
use the address given to manually configure this webhook, for example::

  readthedocs.org/api/v2/webhook/xxxxxxx

Copy the Webhook_ address.

Next create a Webhook_ in your Git_ page.
In GitHub_ this is in the project's ``Settings->Webhooks`` page.
Click on ``Add Webhook`` (this may require your MFA authentication).
In the ``Payload URL`` box paste the above Webhook_ address and click
the green button ``Add webhook``.

.. _Webhook: https://en.wikipedia.org/wiki/Webhook
.. _Integration: https://docs.readthedocs.io/en/stable/integrations.html

E-mail notifications
---------------------------

Configure E-mail notifications to be sent on build failures in the page ``Admin->Email notifications``.
