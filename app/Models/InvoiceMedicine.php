<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class InvoiceMedicine extends Model
{
    protected $table = 'invoice_medicines'; // hoặc 'InvoiceMedicine' nếu bạn dùng PascalCase
    public $timestamps = false;
    protected $primaryKey = null;
    public $incrementing = false;

    protected $fillable = [
        'InvoiceID',
        'MedicineID',
        'Quantity',
    ];

    public function invoice()
    {
        return $this->belongsTo(Invoices::class, 'InvoiceID', 'InvoiceID');
    }

    public function medicines()
    {
        return $this->belongsToMany(Medications::class, 'invoice_medicines', 'InvoiceID', 'MedicineID')
            ->withPivot('Quantity');
    }

}
