### Create your own offline notebook for colorization:

git clone https://github.com/jantic/DeOldify.git

mkdir models
cd models

wget https://data.deepai.org/deoldify/ColorizeVideo_gen.pth

(wget https://media.githubusercontent.com/media/jantic/DeOldify/master/resource_images/watermark.png)

pip install -r colab_requirements.txt
pip install notebook
pip install ipywidgets

./run_notebook.sh
