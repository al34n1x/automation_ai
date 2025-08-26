#!/usr/bin/env python3
"""
Utilidades para trabajar con Oracle Cloud Infrastructure (OCI) Object Storage
"""

import oci
import os
from typing import List, Optional, Union, Dict, Any


def download_file_from_oci(
    namespace: str,
    bucket_name: str,
    object_name: str,
    destination_path: str,
    config: Optional[Dict[str, Any]] = None,
    chunk_size: int = 1024 * 1024,  # 1MB chunks por defecto
) -> str:
    """
    Descarga un archivo desde OCI Object Storage.

    Args:
        namespace (str): Namespace de OCI Object Storage
        bucket_name (str): Nombre del bucket
        object_name (str): Nombre del objeto a descargar
        destination_path (str): Ruta donde se guardará el archivo
        config (Dict, optional): Configuración de OCI. Si es None, se cargará del archivo por defecto
        chunk_size (int, optional): Tamaño del chunk para la descarga en bytes. Por defecto 1MB

    Returns:
        str: Ruta completa del archivo descargado

    Raises:
        oci.exceptions.ServiceError: Si ocurre un error en el servicio de OCI
        FileNotFoundError: Si la ruta de destino no existe
        IOError: Si hay un error al escribir el archivo
    """
    # Cargar configuración de OCI
    if config is None:
        config = oci.config.from_file()

    # Crear cliente de Object Storage
    object_storage = oci.object_storage.ObjectStorageClient(config)

    # Verificar que el directorio de destino existe
    destination_dir = os.path.dirname(destination_path)
    if destination_dir and not os.path.exists(destination_dir):
        os.makedirs(destination_dir)

    # Descargar el objeto
    get_obj = object_storage.get_object(namespace, bucket_name, object_name)
    
    # Guardar el archivo en la ruta especificada
    with open(destination_path, 'wb') as f:
        for chunk in get_obj.data.raw.stream(chunk_size, decode_content=False):
            f.write(chunk)
    
    print(f'Archivo "{object_name}" descargado en "{destination_path}" desde el bucket "{bucket_name}"')
    return destination_path


def download_files_from_oci(
    namespace: str,
    bucket_name: str,
    destination_folder: str,
    prefix: Optional[str] = None,
    config: Optional[Dict[str, Any]] = None,
    chunk_size: int = 1024 * 1024,  # 1MB chunks por defecto
) -> List[str]:
    """
    Descarga múltiples archivos desde OCI Object Storage que coincidan con un prefijo.

    Args:
        namespace (str): Namespace de OCI Object Storage
        bucket_name (str): Nombre del bucket
        destination_folder (str): Carpeta donde se guardarán los archivos
        prefix (str, optional): Prefijo para filtrar los objetos a descargar
        config (Dict, optional): Configuración de OCI. Si es None, se cargará del archivo por defecto
        chunk_size (int, optional): Tamaño del chunk para la descarga en bytes. Por defecto 1MB

    Returns:
        List[str]: Lista de rutas de los archivos descargados

    Raises:
        oci.exceptions.ServiceError: Si ocurre un error en el servicio de OCI
        FileNotFoundError: Si la ruta de destino no existe
        IOError: Si hay un error al escribir algún archivo
    """
    # Cargar configuración de OCI
    if config is None:
        config = oci.config.from_file()

    # Crear cliente de Object Storage
    object_storage = oci.object_storage.ObjectStorageClient(config)

    # Verificar que el directorio de destino existe
    if not os.path.exists(destination_folder):
        os.makedirs(destination_folder)

    # Listar objetos en el bucket
    list_objects_response = object_storage.list_objects(
        namespace, 
        bucket_name, 
        prefix=prefix
    )
    
    downloaded_files = []
    
    # Descargar cada objeto
    for obj in list_objects_response.data.objects:
        file_path = os.path.join(destination_folder, obj.name)
        
        # Crear subdirectorios si es necesario
        file_dir = os.path.dirname(file_path)
        if file_dir and not os.path.exists(file_dir):
            os.makedirs(file_dir)
            
        # Descargar el objeto
        get_obj = object_storage.get_object(namespace, bucket_name, obj.name)
        
        # Guardar el archivo
        with open(file_path, 'wb') as f:
            for chunk in get_obj.data.raw.stream(chunk_size, decode_content=False):
                f.write(chunk)
        
        downloaded_files.append(file_path)
        print(f'Archivo "{obj.name}" descargado en "{file_path}" desde el bucket "{bucket_name}"')
    
    return downloaded_files


# Ejemplo de uso
if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Descargar archivos desde OCI Object Storage')
    parser.add_argument('--namespace', required=True, help='Namespace de OCI Object Storage')
    parser.add_argument('--bucket', required=True, help='Nombre del bucket')
    parser.add_argument('--object', help='Nombre del objeto a descargar (para un solo archivo)')
    parser.add_argument('--prefix', help='Prefijo para filtrar objetos (para múltiples archivos)')
    parser.add_argument('--destination', required=True, help='Ruta de destino para guardar los archivos')
    
    args = parser.parse_args()
    
    # Cargar configuración de OCI
    config = oci.config.from_file()
    
    if args.object:
        # Descargar un solo archivo
        download_file_from_oci(
            args.namespace,
            args.bucket,
            args.object,
            args.destination,
            config
        )
    elif args.prefix:
        # Descargar múltiples archivos
        download_files_from_oci(
            args.namespace,
            args.bucket,
            args.destination,
            args.prefix,
            config
        )
    else:
        print("Debe especificar --object o --prefix")