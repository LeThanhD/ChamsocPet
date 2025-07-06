<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Service extends Model
{
    // Đảm bảo khai báo tên bảng chính xác
    protected $table = 'services';  // Thêm dấu chấm phẩy ở đây

    // Cấu hình khóa chính của bảng
    protected $primaryKey = 'ServiceID';
    public $incrementing = false;  // Khóa chính không tự động tăng
    protected $keyType = 'string'; // Xác định kiểu khóa chính là string (do ServiceID là chuỗi)
    public $timestamps = false;
    // Các trường có thể gán giá trị
    protected $fillable = [
        'ServiceID',
        'ServiceName',
        'Description',
        'Price',
        'CategoryID'
    ];

    // Quan hệ với bảng ServiceCategory
    public function category()
    {
        return $this->belongsTo(ServiceCategory::class, 'CategoryID', 'CategoryID');
    }

    public function appointment()
    {
        return $this->belongsTo(Appointment::class, 'AppointmentID', 'AppointmentID');
    }

    public function invoices()
{
    return $this->belongsToMany(
        Invoices::class,
        'invoice_service',
        'ServiceID',
        'InvoiceID'
    );
}

}
