FROM  ubuntu:16.04
WORKDIR /
RUN apt-get update \
&& \
apt-get install -y wget python python-pip lsb-core g++ libboost-all-dev libgdal-dev gdal-bin python-numpy python-scipy python-gdal cmake++ libeigen3-dev libflann-dev libopenni-dev libqhull-dev qt-sdk libvtk5-qt4-dev libpcap-dev python-vtk libvtk-java libgeotiff-dev python-setuptools libxslt1-dev python-wheel libgeos++-dev libxslt-dev
ENV L2D_CHECKOUT=tags/v1.1.1
ENV LASZIP_CHECKOUT=tags/2.0.2
ENV PCL_CHECKOUT=tags/pcl-1.7.2
ENV GIPPY_VERSION=1.0.3
ENV PDAL_VERSION=1.0.1
#wget http://applied-geosolutions.github.io/lidar2dems/assets/easy-install.sh \
#&& \
#chmod +x easy-install.sh \
#&& \
#./easy-install.sh
# LASzip
RUN git clone https://github.com/LASzip/LASzip.git && \
        cd LASzip && \
        git checkout ${LASZIP_CHECKOUT} && \
        mkdir build && \
        cd build && \
        cmake -G "Unix Makefiles" ../ && \
        make && \
        make install && \
        cd ../..
# points2grid
RUN git clone https://github.com/CRREL/points2grid.git && \
        cd points2grid && \
        mkdir build && \ 
        cd build && \
        cmake -G "Unix Makefiles" ../ && \
        make && \
        make install && \
        cd ../..
# pcl
RUN git clone https://github.com/PointCloudLibrary/pcl.git && \
        cd pcl && \
        mkdir build && \
        cd build && \
        git fetch origin --tags && \
        git checkout tags/pcl-1.7.2 && \
        cmake .. \
            -G "Unix Makefiles" \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_INSTALL_PREFIX=/usr \
            -DBUILD_outofcore:BOOL=OFF \
            -DWITH_QT:BOOL=ON \
            -DWITH_VTK:BOOL=ON \
            -DWITH_OPENNI:BOOL=OFF \
            -DWITH_CUDA:BOOL=OFF \
            -DWITH_LIBUSB:BOOL=OFF \
            -DBUILD_people:BOOL=OFF \
            -DBUILD_surface:BOOL=ON \
            -DBUILD_tools:BOOL=ON \
            -DBUILD_visualization:BOOL=ON \
            -DBUILD_sample_consensus:BOOL=ON \
            -DBUILD_tracking:BOOL=OFF \
            -DBUILD_stereo:BOOL=OFF \
            -DBUILD_keypoints:BOOL=OFF \
            -DBUILD_pipeline:BOOL=ON \
            -DCMAKE_CXX_FLAGS="-std=c++11" \
            -DBUILD_io:BOOL=ON \
            -DBUILD_octree:BOOL=ON \
            -DBUILD_segmentation:BOOL=ON \
            -DBUILD_search:BOOL=ON \
            -DBUILD_geometry:BOOL=ON \
            -DBUILD_filters:BOOL=ON \
            -DBUILD_features:BOOL=ON \
            -DBUILD_kdtree:BOOL=ON \
            -DBUILD_common:BOOL=ON \
            -DBUILD_ml:BOOL=ON && \
        make -j 2 && \
        make install && \
        cd ../..
# pdal
RUN wget https://github.com/PDAL/PDAL/archive/1.0.1.tar.gz && \
        tar -xzf 1.0.1.tar.gz && \
        cd PDAL-1.0.1 && \
        mkdir build && \
        cd build && \
        cmake \
            -G "Unix Makefiles" ../ \
            -DBUILD_PLUGIN_PCL=ON \
            -DBUILD_PLUGIN_P2G=ON \
            -DBUILD_PLUGIN_PYTHON=ON \ 
            -DPDAL_HAVE_GEOS=YES && \
        make -j 2 && \
        make install && \
        cd ../..
# gippy
# gippy archive not available on github RUN pip install https://github.com/Applied-GeoSolutions/gippy/archive/${GIPPY_VERSION}.tar.gz
RUN pip install gippy==${GIPPY_VERSION}
# lidar2dems
RUN pip install lxml, shapely, gdal, fiona==1.7.1 && \
    git clone https://github.com/glw/lidar2dems.git && \
    cd lidar2dems && \
    git checkout ${L2D_CHECKOUT} && \
    ./setup.py install && \
    cd ..
# test lidar2dems
RUN pip install nose && \
    cd lidar2dems ; time nosetests --with-xunit test
WORKDIR /data
CMD ["/bin/bash"]