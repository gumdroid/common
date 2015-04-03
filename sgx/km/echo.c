/*
 * Echo Character Device for Linux
 *
 * Copyright (C) 2014 Ash Charles <ashcharles@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License version 2 as published by the Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 021110-1307, USA.
 */
#include <linux/module.h>
#include <linux/version.h>
#include <linux/fs.h>
#include <linux/device.h>
#include <linux/cdev.h>
#include <asm/uaccess.h>
#include <linux/slab.h>

static dev_t echo_dev;
static struct cdev c_dev;
static struct class *echo_class;
static char *data;

static int echo_open(struct inode *i, struct file *f)
{
	pr_info("Echo: open() -- no-op\n");
	return 0;
}

static int echo_close(struct inode *i, struct file *f)
{
	pr_info("Echo: close() -- no-op\n");
	return 0;
}

static ssize_t echo_read(struct file *file, char __user *buffer, size_t nbytes, loff_t *fpos)
{
	int err;
	
	pr_info("Echo: read()\n");
	err = copy_from_user(data, buffer, nbytes);
	if (err)
		return err;

	return nbytes;
}

static ssize_t echo_write(struct file *file, const char __user *buffer, size_t nbytes, loff_t *fpos)
{
	int err;
	
	pr_info("Echo: read()\n");
	err = copy_to_user(data, buffer, nbytes);
	if (err)
		return err;

	return nbytes;
}

const struct file_operations echo_fops = {
	.owner   = THIS_MODULE,
	.open    = echo_open,
	.release = echo_close,
        .read    = echo_read,
        .write   = echo_write,
};

#define DATA_SIZE 1024

static int __init echo_init(void)
{
	int err;

	err = alloc_chrdev_region(&echo_dev, 0, 1, "echo");
	if (err != 0) {
		pr_warn("Error allocating character device\n");
		goto err_alloc;
	}
	data = kzalloc(DATA_SIZE, GFP_KERNEL);
	if (!data) {
		pr_warn("Error allocating memory\n");
		err = -ENOMEM;
		goto err_alloc;
	}
	echo_class = class_create(THIS_MODULE, "echo");
	if (echo_class == NULL) {
		pr_warn("Error creating echo device class\n");
		goto err_class;
	}
	if (!device_create(echo_class, NULL, echo_dev, NULL, "echo")) {
		pr_warn("Error creating device\n");
		goto err_device;
	}
	cdev_init(&c_dev, &echo_fops);
	err = cdev_add(&c_dev, echo_dev, 1);
	if (err != 0) {
		pr_warn("Error add character device\n");
		goto err_cdev;
	}
	pr_info("echo driver added\n");

	return 0;

err_cdev:
	device_destroy(echo_class, echo_dev);
err_device:
	class_destroy(echo_class);
err_class:
	unregister_chrdev_region(echo_dev, 1);
	kfree(data);
err_alloc:
	return err;
}

static void __exit echo_exit(void)
{
	cdev_del(&c_dev);
	device_destroy(echo_class, echo_dev);
	class_destroy(echo_class);
	kfree(data);
	if (echo_dev)
		unregister_chrdev_region(echo_dev, 1);
	pr_info("echo driver removed\n");
}

module_init(echo_init)
module_exit(echo_exit)
MODULE_AUTHOR("Ash Charles");
MODULE_DESCRIPTION("Echoing Virtual Character Device");
MODULE_LICENSE("GPL");
